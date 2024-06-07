//
//  GameScene.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation
import SpriteKit

final class GameScene: SKScene {

    var viewModel: ViewModel!
        
    var rotation = Rotation.defaultRotation
    let cameraNode = SKCameraNode()
    let rootNode = SKNode()
    let fxRootNode = SKNode()
        
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraScreenPosition = convertWorldToScreen(Vector3D(x: 2, y: 2))
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        cameraNode.setScale(0.5)
        addChild(cameraNode)
        self.camera = cameraNode
        
        addChild(rootNode)
        addChild(fxRootNode)
        
        redraw()
        
        viewModel.redraw = redraw
    }
    
    func redraw() {
        let cameraScreenPosition = convertWorldToScreen(Vector3D(x: 2, y: 2), direction: rotation)
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        
        // cleanup old nodes
        for node in rootNode.children {
            node.removeFromParent()
        }
              
        let map = viewModel.map
        let entities = viewModel.battle.activeEntities
        
        let paths = entities.compactMap { ($0.currentAction as? MoveAction)?.path }
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                let elevation = map[Vector2D(x: x, y: y)]
                for z in 0 ... elevation {
                    let sprite = SKSpriteNode(imageNamed: "Floor_Tile")
                    sprite.texture?.filteringMode = .nearest
                    let position = Vector3D(x: x, y: y, z: z)
                    let screenPosition = convertWorldToScreen(position, direction: rotation)
                    sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                    sprite.zPosition = CGFloat(convertWorldToZPosition(position, direction: rotation))
                    
                    var color = SKColor.white
                    if position == viewModel.selectedTile {
                        color = SKColor.purple
                    } else if paths.contains(where: { $0.contains(position) }) {
                        color = SKColor.blue
                    } else if let currentAction = viewModel.currentAction, let selectedEntity = viewModel.selectedEntity, type(of: currentAction).reachableTiles(in: map, for: selectedEntity, allEntities: viewModel.entities).contains(position) {
                        color = SKColor.systemPink
                    }
                    sprite.colorBlendFactor = 1.0
                    sprite.color = color
                    
                    sprite.userData = ["coord": position] // associate the tile sprite with its coordinate
                    rootNode.addChild(sprite)
                }
            }
        } 
        
        for entity in entities {
            let sprite = SKSpriteNode(imageNamed: getIdleAnimationFirstFrameNameForEntity(entity, referenceRotation: rotation))
            let entityScreenPosition = convertWorldToScreen(entity.position, direction: rotation)
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.3)
            sprite.position = CGPoint(x: entityScreenPosition.x, y: entityScreenPosition.y)
            sprite.zPosition = CGFloat(convertWorldToZPosition(entity.position + Vector3D(x: 0, y: 0, z: 2), direction: rotation))
            
            let animationFX = createAnimationAndFXForEntity(entity)
            
            if let animation = animationFX.animation {
                    sprite.run(animation)
            } else {
                sprite.run(.repeatForever(getAnimationForEntity(entity, animation: "Idle")))
            }
            
            for fx in animationFX.fx {
                fxRootNode.addChild(fx)
            }
            
            rootNode.addChild(sprite)
        }
        
        viewModel.redrawCount += 1
    }
    
    func rotateCW() {
        rotation = rotation.rotated90DegreesClockwise
        redraw()
    }
    
    func rotateCCW() {
        rotation = rotation.rotated90DegreesCounterClockwise
        redraw()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let map = viewModel.map
        
        guard let touch = touches.first else {
            return
        }
        
        let scenePoint = convertPoint(fromView: touch.location(in: view))
        let nodeCoords = nodes(at: scenePoint)
            .sorted(by: { ($0.position - scenePoint).sqrMagnitude < ($1.position - scenePoint).sqrMagnitude })
            .compactMap { node -> Vector3D? in
                guard let coord = node.userData?["coord"] as? Vector3D else {
                    return nil
                }
                
                return coord
            }
            .filter { $0 == map.convertTo3D($0.xy) }
    
        
        
        if let clickedTile = nodeCoords.first {
            viewModel.clickTile(clickedTile)
        }
        
        redraw()
    }    
}

extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    var sqrMagnitude: Double {
        x * x + y * y
    }
}
