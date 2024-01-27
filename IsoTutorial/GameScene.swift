//
//  GameScene.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation
import SpriteKit

final class GameScene: SKScene {

    override func didMove(to view: SKView) {
        size = view.frame.size
        scaleMode = .aspectFill
        
        let cameraNode = SKCameraNode()
        let cameraScreenPosition = convertWorldToScreen(Vector(x: 2, y: 2))
        cameraNode.position = CGPoint(x: cameraScreenPosition.x, y: cameraScreenPosition.y)
        addChild(cameraNode)
        self.camera = cameraNode
        
        for y in -2 ..< 6 {
            for x in -2 ..< 6 {
                let sprite = SKSpriteNode(imageNamed: "Floor_Tile")
                let screenPosition = convertWorldToScreen(Vector(x: x, y: y))
                sprite.position = CGPoint(x: screenPosition.x, y: screenPosition.y)
                sprite.zPosition = -Double(screenPosition.y)
                addChild(sprite)
            }
        }
        
    }
    
}
