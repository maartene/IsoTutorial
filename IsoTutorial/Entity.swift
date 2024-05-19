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
    var currentHP = 10
    let attackRange: Int
    
    init(sprite: String, startPosition: Vector3D, range: Int = Int.max, maxHeightDifference: Int = Int.max, attackRange: Int = 1) {
        self.sprite = sprite
        self.position = startPosition
        self.range = range
        self.maxHeightDifference = maxHeightDifference
        self.attackRange = attackRange
    }
    
    func copy() -> Entity {
        let copy = Entity(sprite: sprite, startPosition: position)
        copy.rotation = rotation
        copy.currentAction = currentAction
        copy.currentHP = currentHP
        return copy
    }
    
    func completeCurrentAction() {
        currentAction?.complete()
        currentAction = nil
    }
    
    func takeDamage(_ amount: Int) {
        currentHP -= amount
        
        currentAction = TakeDamageAction()
    }
}
