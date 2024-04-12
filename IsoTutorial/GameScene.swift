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
        
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraScreenPosition = convertWorldToScreen(Vector3D(x: 2, y: 2))
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        cameraNode.setScale(0.5)
        addChild(cameraNode)
        self.camera = cameraNode
        
        addChild(rootNode)
        
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
        let entities = viewModel.entities
        
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
                    } else if viewModel.currentAction != nil {
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
            if let moveAnimation = createFollowPathAnimationForEntity(entity) {
                    sprite.run(moveAnimation)
            } else {
                sprite.run(.repeatForever(getAnimationForEntity(entity, animation: "Idle")))
            }
            
            rootNode.addChild(sprite)
        }
    }
    
    func rotateCW() {
        rotation = rotation.rotated90DegreesClockwise
        redraw()
    }
    
    func rotateCCW() {
        rotation = rotation.rotated90DegreesCounterClockwise
        redraw()
    }
    
    func getAnimationForEntity(_ entity: Entity, animation: String) -> SKAction {
        let animationName = getAnimationNameForEntity(entity, animation: animation, referenceRotation: rotation)
        let frames = [
            "\(animationName)_0",
            "\(animationName)_1",
            "\(animationName)_2",
            "\(animationName)_3",
        ]
            .map { SKTexture(imageNamed: $0) }
            .map { frame in
                frame.filteringMode = .nearest
                return frame
            }
        
        let animation = SKAction.animate(with: frames, timePerFrame: 0.15)
        return animation
    }
    
    func createFollowPathAnimationForEntity(_ entity: Entity) -> SKAction? {
        guard let moveAction = entity.currentAction as? MoveAction else {
            return nil
        }
        
        var movementActions = [SKAction]()
        let duration = 0.25
        var lastCoord = entity.position.xy
        let stuntDouble = entity.copy()
        for coord in moveAction.path {
            let newRotation = Rotation.fromLookDirection(coord.xy - lastCoord) ?? stuntDouble.rotation
            stuntDouble.rotation = newRotation
            lastCoord = coord.xy
            
            let animation = getAnimationForEntity(stuntDouble, animation: "Walk")
            
            let screenCoord = convertWorldToScreen(coord, direction: rotation)
            let screenPosition = CGPoint(x: screenCoord.x, y: screenCoord.y)
            let movementAction = SKAction.move(to: screenPosition, duration: duration)
            
            let zPosition = convertWorldToZPosition(coord + Vector3D(x: 0, y: 0, z: 2), direction: rotation)
            let zPositionAction = SKAction.customAction(withDuration: duration) { node, time in
                node.zPosition = CGFloat(zPosition)
            }

            movementActions.append(SKAction.group([animation, movementAction, zPositionAction]))
        }
        
        let completeAction = SKAction.customAction(withDuration: 0.001) { [weak self] _, _ in
            entity.completeCurrentAction()
            self?.redraw()
        }
        
        movementActions.append(completeAction)
        
        return SKAction.sequence(movementActions)
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
