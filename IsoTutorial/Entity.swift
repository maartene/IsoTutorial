//
//  Entity.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 17/02/2024.
//

import Foundation

final class Entity {
    let sprite: String
    var position: Vector3D
    var rotation = Rotation.defaultRotation
    
    init(sprite: String, startPosition: Vector3D) {
        self.sprite = sprite
        self.position = startPosition
    }
}
