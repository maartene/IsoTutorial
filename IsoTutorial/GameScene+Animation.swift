//
//  GameScene+Animation.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 24/05/2024.
//

import Foundation
import SpriteKit

extension GameScene {
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
    
    func createAnimationForEntity(_ entity: Entity) -> (action: SKAction?, fx: [SKNode]) {
        guard let currentAction = entity.currentAction else {
            return (nil, [])
        }
        
        switch type(of: currentAction) {
        case is MoveAction.Type:
            return (createFollowPathAnimationForEntity(entity), [])
        case is AttackAction.Type:
            if entity.attackRange == 1 {
                return (createMeleeAttackAnimationForEntity(entity), [])
            } else {
                return createRangedAttackAnimationForEntity(entity)
            }
        case is TakeDamageAction.Type:
            return (createTakeDamageAnimationForEntity(entity), [])
        default:
            print("Not implemented action type \(currentAction). Returning fallback animation (complete only).")
            return (createCompleteActionForEntity(entity), [])
        }
    }
    
    func createCompleteActionForEntity(_ entity: Entity) -> SKAction {
        SKAction.customAction(withDuration: 0.001) { [weak self] _, _ in
            entity.completeCurrentAction()
            self?.redraw()
        }
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
        
        let completeAction = createCompleteActionForEntity(entity)
        
        movementActions.append(completeAction)
        
        return SKAction.sequence(movementActions)
    }
    
    func createMeleeAttackAnimationForEntity(_ entity: Entity) -> SKAction? {
        guard let meleeAttackAction = entity.currentAction as? AttackAction else {
            return nil
        }
        
        guard let target = meleeAttackAction.target else {
            return nil
        }
        
        let stuntDouble = entity.copy()
        let newRotation = Rotation.fromLookDirection(target.position.xy - entity.position.xy) ?? stuntDouble.rotation
        stuntDouble.rotation = newRotation
    
        let attackAnimation = getAnimationForEntity(stuntDouble, animation: "MeleeAttack")
        let completeAction = createCompleteActionForEntity(entity)
        
        return SKAction.sequence([attackAnimation, completeAction])
    }
    
    func createRangedAttackAnimationForEntity(_ entity: Entity) -> (action: SKAction?, fx: [SKNode]) {
        guard let rangedAttackAction = entity.currentAction as? AttackAction else {
            return (nil, [])
        }
        
        guard let target = rangedAttackAction.target else {
            return (nil, [])
        }
        
        let stuntDouble = entity.copy()
        let newRotation = Rotation.fromLookDirection(target.position.xy - entity.position.xy) ?? stuntDouble.rotation
        stuntDouble.rotation = newRotation
    
        let attackAnimation = getAnimationForEntity(stuntDouble, animation: "RangedAttack")
        let completeAction = createCompleteActionForEntity(entity)
        let sequence = SKAction.sequence([attackAnimation, completeAction])
        
        let targetScreenPosition = convertWorldToScreen(target.position + Vector3D(x: 0, y: 0, z: 2), direction: rotation)
        let targetScreenZPosition = convertWorldToZPosition(target.position + Vector3D(x: 0, y: 0, z: 2), direction: rotation)
        
        // fx
        let projectile = SKShapeNode(circleOfRadius: 2)
        projectile.fillColor = .systemGray
        projectile.strokeColor = .systemGray6
        let projectileScreenPosition = convertWorldToScreen(entity.position + Vector3D(x: 0, y: 0, z: 2), direction: rotation)
        let projectileZScreenPosition = max(targetScreenZPosition, convertWorldToZPosition(entity.position + Vector3D(x: 0, y: 0, z: 2), direction: rotation))
        projectile.position = CGPoint(x: projectileScreenPosition.x, y: projectileScreenPosition.y)
        projectile.zPosition = CGFloat(projectileZScreenPosition)
        
        
        let projectileMoveAction = SKAction.move(to: CGPoint(x: targetScreenPosition.x, y: targetScreenPosition.y), duration: 0.25)
        let projectileAction = SKAction.sequence([.hide(), .wait(forDuration: attackAnimation.duration), .unhide(), projectileMoveAction, .removeFromParent()])
        projectile.run(projectileAction)
        
        return (sequence, [projectile])
    }
    
    func createTakeDamageAnimationForEntity(_ entity: Entity) -> SKAction? {
        let stuntDouble = entity.copy()
        let animation = getAnimationForEntity(stuntDouble, animation: "TakeDamage")
        let completeAction = createCompleteActionForEntity(entity)
        
        return SKAction.sequence([animation, completeAction])
    }
}
