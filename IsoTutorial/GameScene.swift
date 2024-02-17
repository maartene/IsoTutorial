//
//  GameScene.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation
import SpriteKit

final class GameScene: SKScene {

    let heightmap = [
        [1,1,1,1,1],
        [1,1,1,1,1],
        [1,1,2,2,1],
        [2,4,2,3,1],
        [1,1,1,1,1],
    ]
    
    var rotation = Rotation.defaultRotation
    let cameraNode = SKCameraNode()
    let rootNode = SKNode()
    
    let entities = [
        Entity(sprite: "Knight", startPosition: Vector(x: 1, y: 1, z: 1)),
        Entity(sprite: "Knight", startPosition: Vector(x: 3, y: 3, z: 3)),
        Entity(sprite: "Rogue", startPosition: Vector(x: 4, y: 0, z: 1))
    ]
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraScreenPosition = convertWorldToScreen(Vector(x: 2, y: 2))
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        cameraNode.setScale(0.5)
        addChild(cameraNode)
        self.camera = cameraNode
        
        addChild(rootNode)
        
        redraw()
    }
    
    func redraw() {
        let cameraScreenPosition = convertWorldToScreen(Vector(x: 2, y: 2), direction: rotation)
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        
        // cleanup old nodes
        for node in rootNode.children {
            node.removeFromParent()
        }
        
        for y in 0 ..< heightmap.count {
            for x in 0 ..< heightmap[y].count {
                let elevation = heightmap[y][x]
                for z in 0 ..< elevation {
                    let sprite = SKSpriteNode(imageNamed: "Floor_Tile")
                    sprite.texture?.filteringMode = .nearest
                    let position = Vector(x: x, y: y, z: z)
                    let screenPosition = convertWorldToScreen(position, direction: rotation)
                    sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                    sprite.zPosition = CGFloat(convertWorldToZPosition(position, direction: rotation))
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
        let x = (0 ..< heightmap[0].count).randomElement()!
        let y = (0 ..< heightmap.count).randomElement()!
        let z = heightmap[y][x]
        entity.position = Vector(x: x, y: y, z: z)
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
}
