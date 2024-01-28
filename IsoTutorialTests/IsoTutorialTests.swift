//
//  IsoTutorialTests.swift
//  IsoTutorialTests
//
//  Created by Maarten Engels on 27/01/2024.
//

import XCTest
@testable import IsoTutorial

final class IsoTutorialTests: XCTestCase {

    func test_increasingXbyOne_OffsetsXandYInScreenSpace_by_16and8() {
        let coordinateInWorldSpace = Vector(x: 1, y: 0)
        let expectedCoordinateInScreenSpace = Vector(x: 16, y: 8)
        XCTAssertEqual(convertWorldToScreen(coordinateInWorldSpace), expectedCoordinateInScreenSpace)
    }
    
    func test_increasingYByOne_OffsetsXandYInScreenSpace_by_minus16and8() {
        let coordinateInWorldSpace = Vector(x: 0, y: 1)
        let expectedCoordinateInScreenSpace = Vector(x: -16, y: 8)
        XCTAssertEqual(convertWorldToScreen(coordinateInWorldSpace), expectedCoordinateInScreenSpace)
    }
    
    func test_linearBehaviourOf_convertWorldToScreen() {
        let worldCoordinates = [
            Vector(x: -1, y: 2),
            Vector(x: 2, y: 2),
            Vector(x: 2, y: -1),
            Vector(x: -1, y: 0),
            Vector(x: 0, y: -1),
            Vector(x: -1, y: -1),
        ]
        
        let expectedScreenSpaceCoordinates = [
            Vector(x: -48, y: 8),
            Vector(x: 0, y: 32),
            Vector(x: 48, y: 8),
            Vector(x: -16, y: -8),
            Vector(x: 16, y: -8),
            Vector(x: 0, y: -16),
        ]
        
        for i in 0 ..< worldCoordinates.count {
            XCTAssertEqual(convertWorldToScreen(worldCoordinates[i]), expectedScreenSpaceCoordinates[i])
        }
    }
    
    // MARK: 3rd dimension
    func test_convertWorldToScreen_increasingZByOne_movesYby8() {
        let coordinateInWorldSpace = Vector(x: 0, y: 0, z: 1)
        let expectedCoordinateInScreenSpace = Vector(x: 0, y: 8)
        XCTAssertEqual(convertWorldToScreen(coordinateInWorldSpace), expectedCoordinateInScreenSpace)
    }
    
    func test_convertWorldToScreen_someMoreTestsWithZValues() {
        let worldCoordinates = [
            Vector(x: 1, y: 0, z: 1),
            Vector(x: 1, y: 1, z: 2),
            Vector(x: -1, y: 0, z: 1),
            Vector(x: -1, y: 2, z: 2)
        ]
        
        let expectedScreenSpaceCoordinates = [
            Vector(x: 16, y: 16),
            Vector(x: 0, y: 32),
            Vector(x: -16, y: 0),
            Vector(x: -48, y: 24),
        ]
        for i in 0 ..< worldCoordinates.count {
            XCTAssertEqual(convertWorldToScreen(worldCoordinates[i]), expectedScreenSpaceCoordinates[i])
        }
    }
    
    // MARK: zPosition
    func test_convertWorldToZPosition_returnsHigherZValues_for_coordinatesClosedToCamera_2D() {
        let testcases: [(coord: Vector, before: [Vector], behind: [Vector])] = [
            (Vector(x: -1, y: -1), [Vector(x: -1, y: 0), Vector(x: 0, y: -1)], []),
            (Vector(x: 0, y: 0), [Vector(x: 0, y: 1), Vector(x: 1, y: 0)], [Vector(x: -1, y: 0), Vector(x: 0, y: -1)]),
            (Vector(x: 1, y: 0), [Vector(x: 1, y: 1), Vector(x: 2, y: 0)], [Vector(x: 0, y: 0), Vector(x: 1, y: -1)]),
        ]
        
        for testcase in testcases {
            for beforeCoord in testcase.before {
                XCTAssertGreaterThan(convertWorldToZPosition(testcase.coord), convertWorldToZPosition(beforeCoord))
            }
            for behindCoord in testcase.behind {
                XCTAssertLessThan(convertWorldToZPosition(testcase.coord), convertWorldToZPosition(behindCoord))
            }
        }
    }
    
    func test_convertWorldToZPosition_returnsHigherZValues_for_coordinatesClosedToCamera_3D() {
        let testcases: [(coord: Vector, before: [Vector], behind: [Vector])] = [
            (Vector(x: -1, y: 0, z: 1),
             [Vector(x: 0, y: 0, z: 0), Vector(x: 0, y: 1, z: 0)],
             []
            ),
            (Vector(x: 1, y: 1, z: 1),
             [Vector(x: 1, y: 1, z: 0)],
             [Vector(x: 1, y: 1, z: 2), Vector(x: 1, y: 0, z: 1)]
            ),
            (Vector(x: -1, y: 2, z: 1),
             [Vector(x: -1, y: 2, z: 0), Vector(x: 0, y: 2, z: 0)],
             [Vector(x: -1, y: 2, z: 2)]
            ),
        ]
        
        for testcase in testcases {
            for beforeCoord in testcase.before {
                XCTAssertGreaterThan(convertWorldToZPosition(testcase.coord), convertWorldToZPosition(beforeCoord))
            }
            for behindCoord in testcase.behind {
                XCTAssertLessThan(convertWorldToZPosition(testcase.coord), convertWorldToZPosition(behindCoord))
            }
        }
    }
}
