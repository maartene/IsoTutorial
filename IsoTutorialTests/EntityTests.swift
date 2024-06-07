//
//  EntityTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 23/03/2024.
//

import Foundation
import XCTest
@testable import IsoTutorial

final class EntityTests: XCTestCase {
    // MARK: Copy constructor tests
    func test_copy_returnsAnewInstance() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        let copy = entity.copy()
        XCTAssertTrue(entity !== copy)
    }
    
    func test_copy_returnsAnInstanceWithSamePropertiesAsOriginal() {
        let entity = Entity(sprite: UUID().uuidString, startPosition: Vector3D.random, team: "team \(Int.random(in: 0 ... 1000))")
        entity.rotation = .degrees225
        entity.currentAction = DummyAction()
        entity.currentHP -= 1
        
        let copy = entity.copy()
        
        XCTAssertEqual(copy.sprite, entity.sprite)
        XCTAssertEqual(copy.position, entity.position)
        XCTAssertEqual(copy.rotation, entity.rotation)
        XCTAssertEqual(copy.team, entity.team)
        XCTAssertEqual(copy.currentAction?.description, entity.currentAction?.description)
        XCTAssertEqual(copy.currentHP, entity.currentHP)
    }
    
    // MARK: Complete Actions
    func test_completeCurrentAction_setsCurrentActionToNil() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        entity.currentAction = DummyAction()
        entity.completeCurrentAction()
        
        XCTAssertNil(entity.currentAction)
    }
    
    func test_completeCurrentAction_callsActionsComplete() {
        struct BlockAction: Action {
            let block: () -> Void
            
            func complete() {
                block()
            }
            
            static func make(in map: Map, for entity: Entity, targetting: Vector3D, allEntities: [Entity] = []) -> BlockAction? {
                BlockAction(block: { })
            }
        }
        
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        var count = 0
        entity.currentAction = BlockAction { count += 1 }
        entity.completeCurrentAction()
        XCTAssertEqual(count, 1)
    }
    
    func test_completeCurrentAction_sets_hasActed_toTrue_whenCurrentAction_endsTurn() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        entity.currentAction = DummyAction()
        entity.completeCurrentAction()
        XCTAssertTrue(entity.hasActed)
    }
    
    func test_completeCurrentAction_doesNotSet_hasActed_toTrue_whenCurrentAction_isNil() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        entity.completeCurrentAction()
        XCTAssertFalse(entity.hasActed)
    }
    
    func test_completeCurrentAction_doesNotSet_hasActed_toTrue_whenCurrentAction_doesNotEndTurn() {
        struct DummyActionThatDoesNotEndTurn: Action {
            static func make(in map: IsoTutorial.Map, for entity: IsoTutorial.Entity, targetting: IsoTutorial.Vector3D, allEntities: [IsoTutorial.Entity]) -> DummyActionThatDoesNotEndTurn? {
                DummyActionThatDoesNotEndTurn()
            }
            
            let endsTurn = false
        }
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        entity.currentAction = DummyActionThatDoesNotEndTurn()
        entity.completeCurrentAction()
        
        XCTAssertFalse(entity.hasActed)
    }
    
    // MARK: TakeDamage
    func test_takeDamage_lowersHP() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        let originalHP = entity.currentHP
        
        entity.takeDamage(3)
        
        XCTAssertEqual(entity.currentHP, originalHP - 3)
    }
    
    func test_takeDamage_setsCurrentAction_toTakeDamage() throws {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        
        entity.takeDamage(3)
        
        let currentAction = try XCTUnwrap(entity.currentAction)
        
        XCTAssertTrue(currentAction is TakeDamageAction)
    }
    
    func test_takeDamage_ifHPbecomesLessThanZero_isActive_isFalse() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        
        entity.takeDamage(entity.currentHP)
        
        XCTAssertFalse(entity.isActive)
    }
    
    func test_takeDamage_ifHPDoesNotBecomeLessThanZero_isActive_isTrue() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        
        entity.takeDamage(entity.currentHP - 1)
        
        XCTAssertTrue(entity.isActive)
    }
    
    // MARK: Teams
    func test_aNewEntity_doesNotHaveATeam() {
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        XCTAssertEqual(entity.team, "")
    }
    
    func test_canSetATeam_forANewEntity_whenPassingInATeam() {
        let entity = Entity(sprite: "Entity", startPosition: .zero, team: "A-Team")
        XCTAssertEqual(entity.team, "A-Team")
    }
}
