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
    var currentAction: Action?
    let range: Int
    let maxHeightDifference: Int
    
    init(sprite: String, startPosition: Vector3D, range: Int = Int.max, maxHeightDifference: Int = Int.max) {
        self.sprite = sprite
        self.position = startPosition
        self.range = range
        self.maxHeightDifference = maxHeightDifference
    }
    
    func copy() -> Entity {
        let copy = Entity(sprite: sprite, startPosition: position)
        copy.rotation = rotation
        return copy
    }
    
    func completeCurrentAction() {
        currentAction?.complete()
        currentAction = nil
    }
}
