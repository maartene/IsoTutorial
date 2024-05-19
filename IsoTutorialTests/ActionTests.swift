//
//  ActionTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 28/03/2024.
//

import Foundation
import XCTest
@testable import IsoTutorial

final class ActionTests: XCTestCase {
    
    let exampleMap = Map(heightMap: [
        [1,1,1,1,1,2,3],
        [1,1,3,3,3,1,1],
        [1,1,3,5,4,1,5],
        [1,1,2,2,2,1,4],
        [1,1,1,1,1,1,3],
        [1,1,1,1,1,1,2],
        [1,1,1,1,1,1,1],
    ])
    
    // MARK: MoveAction
    func test_moveAction_complete_setsPosition() {
        let entity = Entity(sprite: "Example", startPosition: .zero)
        let path = [
            Vector3D(x: 0, y: 0, z: 0),
            Vector3D(x: 0, y: 1, z: 1),
            Vector3D(x: 0, y: 2, z: 1),
            Vector3D(x: 1, y: 2, z: 1),
            Vector3D(x: 2, y: 2, z: 2),
            Vector3D(x: 3, y: 2, z: 2),
        ]
        
        let moveAction = MoveAction(owner: entity, path: path)
        
        moveAction.complete()
        
        XCTAssertEqual(entity.position, path.last)
    }
    
    func test_moveAction_complete_setsRotation() {
        let entity = Entity(sprite: "Example", startPosition: .zero)
        let path = [
            Vector3D(x: 0, y: 0, z: 0),
            Vector3D(x: 0, y: -1, z: 1),
            Vector3D(x: 0, y: -2, z: 1),
        ]
        
        let moveAction = MoveAction(owner: entity, path: path)
        
        moveAction.complete()
        
        XCTAssertEqual(entity.rotation, .degrees315)
    }
    
    func test_moveAction_make_isBasedOnPathfinding() throws {
        let entity = Entity(sprite: "Example Entity", startPosition: .zero)
        let targetPosition = Vector2D(x: 1, y: 1)
        let expectedPath = [
            Vector3D(x: 0, y: 0, z: 1),
            Vector3D(x: 0, y: 1, z: 1),
            Vector3D(x: 1, y: 1, z: 1)
        ]
        
        let action = try XCTUnwrap(MoveAction.make(in: exampleMap, for: entity, targetting: exampleMap.convertTo3D(targetPosition)))
                
        XCTAssertEqual(action.path, expectedPath)
    }
    
    func test_moveAction_description() {
        let path = [
            Vector3D(x: 2, y: 2, z: 3),
            Vector3D(x: 2, y: 1, z: 2),
            Vector3D(x: 1, y: 1, z: 1)
        ]
        
        let action = MoveAction(path: path)
        XCTAssertEqual(action.description, "Move to (\(path[2].x),\(path[2].y))")
    }
    
    func test_moveAction_description_emptyPath() {
        let action = MoveAction(path: [])
        XCTAssertEqual(action.description, "Move to...")
    }
    
    func test_moveAction_canComplete_returnsFalse_whenPathIsEmpty() {
        let action = MoveAction(path: [])
        XCTAssertFalse(action.canComplete)
    }
    
    func test_moveAction_canComplete_returnsTrue_whenPathIsNotEmpty() {
        let action = MoveAction(path: [Vector3D(x: 1, y: 2, z: 3)])
        XCTAssertTrue(action.canComplete)
    }
    
    func test_moveAction_reachableTiles_returns_tilesWithinRange_of_entity() {
        let entity = Entity(sprite: "Example Entity", startPosition: Vector3D(x: 1, y: 1, z: 1), range: 3)
        
        let expectedReachableTiles = [
            Vector3D(x: 0, y: 2, z: 1),
            Vector3D(x: 1, y: 4, z: 1),
            Vector3D(x: 0, y: 0, z: 1),
            Vector3D(x: 0, y: 1, z: 1),
            Vector3D(x: 1, y: 2, z: 1),
            Vector3D(x: 2, y: 0, z: 1),
            Vector3D(x: 3, y: 0, z: 1),
            Vector3D(x: 1, y: 1, z: 1),
            Vector3D(x: 1, y: 3, z: 1),
            Vector3D(x: 0, y: 3, z: 1),
            Vector3D(x: 2, y: 1, z: 3),
            Vector3D(x: 1, y: 0, z: 1)
        ]
        
        let reachableTiles = MoveAction.reachableTiles(in: exampleMap, for: entity)
        
        XCTAssertEqual(reachableTiles.count, expectedReachableTiles.count)
        
        for reachableTile in reachableTiles {
            XCTAssertTrue(expectedReachableTiles.contains(reachableTile))
        }
    }
    
    func test_moveAction_make_returnsNil_whenACoord_thatIsNotIn_reachableTiles_isPassedIn() {
        let entity = Entity(sprite: "Example Entity", startPosition: Vector3D(x: 1, y: 1, z: 1), range: 3)
        
        let maybeMoveAction = MoveAction.make(in: exampleMap, for: entity, targetting: Vector3D(x: 4, y: 4, z: 1))
        
        XCTAssertNil(maybeMoveAction)
    }
    
    func test_moveAction_reachableTiles_returns_lessTilesWithinRange_for_entity_withShorterRange() {
        let shortRangeEntity = Entity(sprite: "Short Range Entity", startPosition: Vector3D(x: 2, y: 2, z: 1), range: 2)
        let longRangeEntity = Entity(sprite: "Long Range Entity", startPosition: Vector3D(x: 2, y: 2, z: 1), range: 3)
        
        let map = Map(heightMap: [
          [1,1,1,1,1],
          [1,1,1,1,1],
          [1,1,1,1,1],
          [1,1,1,1,1],
          [1,1,1,1,1],
        ])
        
        XCTAssertLessThan(
            MoveAction.reachableTiles(in: map, for: shortRangeEntity).count,
            MoveAction.reachableTiles(in: map, for: longRangeEntity).count
        )
    }
    
    func test_moveAction_reachableTiles_takesMaximumHeightDifference_intoAccount() throws {
        let entity = Entity(sprite: "Example Entity", startPosition: Vector3D(x: 0, y: 0, z: 1), range: Int.max, maxHeightDifference: 1)
        
        let reachableTiles = MoveAction.reachableTiles(in: Map(heightMap: [
            [1,1,1],
            [1,3,1],
            [1,1,1],
        ]), for: entity)
        
        let expectedReachableTiles = [
            Vector3D(x: 0, y: 0, z: 1),
            Vector3D(x: 1, y: 0, z: 1),
            Vector3D(x: 2, y: 0, z: 1),
            Vector3D(x: 0, y: 1, z: 1),
            Vector3D(x: 2, y: 1, z: 1),
            Vector3D(x: 0, y: 2, z: 1),
            Vector3D(x: 1, y: 2, z: 1),
            Vector3D(x: 2, y: 2, z: 1),
        ]
                
        XCTAssertEqual(reachableTiles.count, expectedReachableTiles.count)
        
        for reachableTile in reachableTiles {
            XCTAssertTrue(expectedReachableTiles.contains(reachableTile))
        }
    }
    
    func test_moveAction_make_takesMaximumHeightDifference_intoAccount() throws {
        let entity = Entity(sprite: "Example Entity", startPosition: .zero, range: Int.max, maxHeightDifference: 1)
    
        let moveAction = try XCTUnwrap(MoveAction.make(in: exampleMap, for: entity, targetting: Vector3D(x: 2, y: 1, z: 3)))
        
        let expected = [
            Vector3D(x: 0, y: 0, z: 1),
            Vector3D(x: 0, y: 1, z: 1),
            Vector3D(x: 0, y: 2, z: 1),
            Vector3D(x: 0, y: 3, z: 1),
            Vector3D(x: 1, y: 3, z: 1),
            Vector3D(x: 2, y: 3, z: 2),
            Vector3D(x: 2, y: 2, z: 3),
            Vector3D(x: 2, y: 1, z: 3)
        ]
        
        XCTAssertEqual(moveAction.path, expected)
    }
    
    func test_moveAction_reachableTiles_doesNotContain_occupiedTiles() {
        let entity = Entity(sprite: "Example Entity", startPosition: .zero)
        let otherEntity = Entity(sprite: "I'm in the way", startPosition: Vector3D(x: 1, y: 1, z: 1))
        
        let reachableTiles = MoveAction.reachableTiles(in: exampleMap, for: entity, allEntities: [entity, otherEntity])
        
        XCTAssertFalse(reachableTiles.contains(otherEntity.position))
    }
    
    func test_moveAction_make_returnsNil_forOccupiedTile() {
        let entity = Entity(sprite: "Example Entity", startPosition: .zero)
        let otherEntity = Entity(sprite: "I'm in the way", startPosition: Vector3D(x: 1, y: 1, z: 1))
        
        let maybeMoveAction = MoveAction.make(in: exampleMap, for: entity, targetting: otherEntity.position, allEntities: [entity, otherEntity])
        
        XCTAssertNil(maybeMoveAction)
    }
    
    // MARK: (Melee)AttackAction
    func test_attackAction_complete_lowersHPOfTarget() {
        let entity = Entity(sprite: "Example Entity", startPosition: .zero)
        let originalHP = entity.currentHP
        let attackAction = AttackAction(target: entity)
        
        attackAction.complete()
        
        XCTAssertLessThan(entity.currentHP, originalHP)
    }
    
    func test_attackAction_make_setsTarget_toEntity_atPosition() throws {
        let entity = Entity(sprite: "Example Entity", startPosition: Vector3D(x: 0, y: 0, z: 1))
        let target = Entity(sprite: "Target Entity", startPosition: Vector3D(x: 0, y: 1, z: 1))

        let attackAction = try XCTUnwrap(AttackAction.make(in: exampleMap, for: entity, targetting: target.position, allEntities: [entity, target]))
        
        let targetInAction = try XCTUnwrap(attackAction.target)
        XCTAssertTrue(targetInAction === target)
    }
    
    func test_attackAction_make_returnsNil_whenPositionWithoutEntity_isPassedIn() {
        let entity = Entity(sprite: "Example Entity", startPosition: Vector3D(x: 0, y: 0, z: 1))
        let target = Entity(sprite: "Target Entity", startPosition: Vector3D(x: 0, y: 1, z: 1))

        let maybeAttackAction = AttackAction.make(in: exampleMap, for: entity, targetting: Vector3D(x: 1, y: 0, z: 1), allEntities: [entity, target])
        
        XCTAssertNil(maybeAttackAction)
    }
    
    func test_attackAction_make_returnsNil_whenPositionOutOfRange_isPassedIn() {
        let entity = Entity(sprite: "Example Entity", startPosition: Vector3D(x: 0, y: 0, z: 1))
        let target = Entity(sprite: "Target Entity", startPosition: Vector3D(x: 0, y: 2, z: 1))
        
        let maybeAttackAction = AttackAction.make(in: exampleMap, for: entity, targetting: target.position, allEntities: [entity, target])
        
        XCTAssertNil(maybeAttackAction)
    }
    
    func test_attackAction_canComplete_returnsFalse_whenTargetIsNil() {
        let attackAction = AttackAction(target: nil)
        XCTAssertFalse(attackAction.canComplete)
    }
    
    func test_attackAction_canComplete_returnsTrue_whenTargetIsNotNil() {
        let target = Entity(sprite: "Target", startPosition: .zero)
        let attackAction = AttackAction(target: target)
        XCTAssertTrue(attackAction.canComplete)
    }
    
    func test_attackAction_description() {
        let target = Entity(sprite: "Target", startPosition: .zero)
        
        let attackAction = AttackAction(target: target)
        XCTAssertEqual(attackAction.description, "Attack Target")
    }
    
    func test_attackAction_afterCompletion_targetAndAttacker_faceEachother() {
        let attacker = Entity(sprite: "Attacking Entity", startPosition: Vector3D(x: 0, y: 0, z: 1))
        let target = Entity(sprite: "Target Entity", startPosition: Vector3D(x: 0, y: 1, z: 1))

        let attackAction = AttackAction(owner: attacker, target: target)
        attackAction.complete()
        
        XCTAssertEqual(attacker.rotation, .degrees135)
        XCTAssertEqual(target.rotation, .degrees315)
    }
    
    // MARK: Ranged attacks
    func test_attackAction_make_doesNotReturnNil_whenWithinRangedAttackRange() {
        let attacker = Entity(sprite: "Attacking Entity", startPosition: Vector3D(x: 0, y: 0, z: 1), attackRange: 3)
        let target = Entity(sprite: "Target Entity", startPosition: Vector3D(x: 0, y: 3, z: 1))
        
        let maybeAttackAction = AttackAction.make(in: exampleMap, for: attacker, targetting: target.position, allEntities: [attacker, target])
        
        XCTAssertNotNil(maybeAttackAction)
    }
    
    func test_attackAction_afterCompletion_ofRangedAttack_attackerAndTarget_faceEachother() {
        let attacker = Entity(sprite: "Attacking Entity", startPosition: Vector3D(x: 0, y: 0, z: 1), attackRange: 3)
        let target = Entity(sprite: "Target Entity", startPosition: Vector3D(x: 0, y: 3, z: 1))
        
        let attackAction = AttackAction(owner: attacker, target: target)
        
        attackAction.complete()
        
        XCTAssertEqual(attacker.rotation, .degrees135)
        XCTAssertEqual(target.rotation, .degrees315)
    }
    
}
