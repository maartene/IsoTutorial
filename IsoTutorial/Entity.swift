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
    //var currentHP = 1
    let attackRange: Int
    var team: String
    var hasActed = false
    
    init(sprite: String, startPosition: Vector3D, range: Int = Int.max, maxHeightDifference: Int = Int.max, attackRange: Int = 1, team: String = "") {
        self.sprite = sprite
        self.position = startPosition
        self.range = range
        self.maxHeightDifference = maxHeightDifference
        self.attackRange = attackRange
        self.team = team
    }
    
    func copy() -> Entity {
        let copy = Entity(sprite: sprite, startPosition: position, team: team)
        copy.rotation = rotation
        copy.currentAction = currentAction
        copy.currentHP = currentHP
        return copy
    }
    
    func completeCurrentAction() {
        currentAction?.complete()
        if currentAction?.endsTurn ?? false {
            hasActed = true
        }
        currentAction = nil
    }
    
    func takeDamage(_ amount: Int) {
        currentHP -= amount
        if currentHP <= 0 {
            currentAction = DefeatAction()
        } else {
            currentAction = TakeDamageAction()
        }
    }
    
    var isActive: Bool {
        currentHP > 0
    }
}
