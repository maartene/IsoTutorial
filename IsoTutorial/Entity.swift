//
//  Entity.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 10/02/2024.
//

import Foundation

final class Entity {
    let sprite: String
    var position: Vector
    var rotation = Rotation.defaultRotation
    
    init(sprite: String, startPosition: Vector) {
        self.sprite = sprite
        self.position = startPosition
    }
}
