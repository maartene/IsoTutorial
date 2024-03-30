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
        
        let copy = entity.copy()
        
        XCTAssertEqual(copy.sprite, entity.sprite)
        XCTAssertEqual(copy.position, entity.position)
        XCTAssertEqual(copy.rotation, entity.rotation)
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
        }
        
        let entity = Entity(sprite: "Entity", startPosition: .zero)
        var count = 0
        entity.currentAction = BlockAction { count += 1 }
        entity.completeCurrentAction()
        XCTAssertEqual(count, 1)
    }
}
