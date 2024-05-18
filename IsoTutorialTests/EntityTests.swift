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
        let entity = Entity(sprite: UUID().uuidString, startPosition: Vector3D.random)
        entity.rotation = .degrees225
        entity.currentAction = DummyAction()
        entity.currentHP -= 1
        
        let copy = entity.copy()
        
        XCTAssertEqual(copy.sprite, entity.sprite)
        XCTAssertEqual(copy.position, entity.position)
        XCTAssertEqual(copy.rotation, entity.rotation)
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
}
