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
    
    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraScreenPosition = convertWorldToScreen(Vector(x: 2, y: 2))
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
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
                    let position = Vector(x: x, y: y, z: z)
                    let screenPosition = convertWorldToScreen(position, direction: rotation)
                    sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                    sprite.zPosition = CGFloat(convertWorldToZPosition(position, direction: rotation))
                    rootNode.addChild(sprite)
                }
            }
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
}
