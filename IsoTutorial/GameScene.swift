//
//  GameScene.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation
import SpriteKit

final class GameScene: SKScene {

    let map = Map(heightMap: [
        [1,1,1,1,1],
        [1,1,1,1,1],
        [1,1,2,2,1],
        [2,4,2,3,1],
        [1,1,1,1,1],
    ])
    
    var rotation = Rotation.defaultRotation
    let cameraNode = SKCameraNode()
    let rootNode = SKNode()
    
    // just so we can show the Dijkstra map
    var dijkstra = [Vector2D: Int]()
    var selectedCoord: Vector2D?
    
    let entities = [
        Entity(sprite: "Knight", startPosition: Vector3D(x: 1, y: 1, z: 1)),
        Entity(sprite: "Knight", startPosition: Vector3D(x: 3, y: 3, z: 3)),
        Entity(sprite: "Rogue", startPosition: Vector3D(x: 4, y: 0, z: 1))
    ]
    
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
    }
    
    func redraw() {
        let cameraScreenPosition = convertWorldToScreen(Vector3D(x: 2, y: 2), direction: rotation)
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        
        // cleanup old nodes
        for node in rootNode.children {
            node.removeFromParent()
        }
        
        // create dijkstramap if a tile is selected, just to show it.
        if let selectedCoord {
            dijkstra = map.dijkstra(target: selectedCoord)
        } else {
            dijkstra.removeAll()
        }
        
        for y in 0 ..< map.rowCount {
            for x in 0 ..< map.colCount {
                let elevation = map[Vector2D(x: x, y: y)]
                for z in 0 ..< elevation {
                    let sprite = SKSpriteNode(imageNamed: "Floor_Tile")
                    sprite.texture?.filteringMode = .nearest
                    let position = Vector3D(x: x, y: y, z: z)
                    let screenPosition = convertWorldToScreen(position, direction: rotation)
                    sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                    sprite.zPosition = CGFloat(convertWorldToZPosition(position, direction: rotation))
                    
                    // Just to show the Dijkstramap
                    var color = SKColor.white
                    if let distance = dijkstra[position.xy] {
                        let hue = Double(distance) / 10.0
                        color = SKColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
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
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.4)
            sprite.position = CGPoint(x: entityScreenPosition.x, y: entityScreenPosition.y)
            sprite.zPosition = CGFloat(convertWorldToZPosition(entity.position, direction: rotation))
            sprite.run(getIdleAnimationForEntity(entity))
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
    
    func rotateKnightCW() {
        entities[0].rotation = entities[0].rotation.rotated90DegreesClockwise
        redraw()
    }
    
    func rotateKnightCCW() {
        entities[0].rotation = entities[0].rotation.rotated90DegreesCounterClockwise
        redraw()
    }
    
    func moveRandomEntityToRandomPosition() {
        let entity = entities.randomElement()!
        let x = (0 ..< map.colCount).randomElement()!
        let y = (0 ..< map.rowCount).randomElement()!
        entity.position = map.convertTo3D(Vector2D(x: x, y: y))
        redraw()
    }
    
    func getIdleAnimationForEntity(_ entity: Entity) -> SKAction {
        let animationName = getIdleAnimationNameForEntity(entity, referenceRotation: rotation)
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
        
        let idleAnimation = SKAction.animate(with: frames, timePerFrame: 0.25)
        return SKAction.repeatForever(idleAnimation)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        let scenePoint = convertPoint(fromView: touch.location(in: view))
        guard let node = nodes(at: scenePoint).first else {
            return
        }
        
        guard let coord = node.userData?["coord"] as? Vector3D else {
            return
        }
        
        selectedCoord = coord.xy
        redraw()
    }
}
