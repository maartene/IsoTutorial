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

}
