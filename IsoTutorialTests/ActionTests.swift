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
}
