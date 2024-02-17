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
    
    // MARK: Rotation
    
    func test_rotateCoordinate_returnsInputCoordinate_forDefaultRotation() {
        let inputCoordinates = [
            Vector(x: -1, y: 1, z: 0),
            Vector(x: -3, y: 1, z: -2),
            Vector(x: 3, y: 3, z: 2),
        ]
        
        for coord in inputCoordinates {
            XCTAssertEqual(rotateCoordinate(coord, direction: .defaultRotation), coord)
        }
    }
    
    func test_rotateCoordinate_returnsExpectedCoordinates_forClockWiseRotation() throws {
        let inputCoordinates = [
            Vector(x: 5, y: 2, z: 0),
            Vector(x: -1, y: 3, z: 0),
            Vector(x: -3, y: -7, z: 0),
            Vector(x: 4, y: -2, z: 0),
        ]
        
        let expectedCoordinates = [
            Vector(x: 2, y: -5, z: 0),
            Vector(x: 3, y: 1, z: 0),
            Vector(x: -7, y: 3, z: 0),
            Vector(x: -2, y: -4, z: 0),
        ]
        
        for i in 0 ..< inputCoordinates.count {
            XCTAssertEqual(rotateCoordinate(inputCoordinates[i], direction: .defaultRotation.rotated90DegreesClockwise), expectedCoordinates[i])
        }
    }
    
    func test_rotateCoordinate_returnsExpectedCoordinates_forCounterClockWiseRotation() throws {
        let inputCoordinates = [
            Vector(x: 2, y: -5, z: 0),
            Vector(x: 3, y: 1, z: 0),
            Vector(x: -7, y: 3, z: 0),
            Vector(x: -2, y: -4, z: 0),
        ]
        
        let expectedCoordinates = [
            Vector(x: 5, y: 2, z: 0),
            Vector(x: -1, y: 3, z: 0),
            Vector(x: -3, y: -7, z: 0),
            Vector(x: 4, y: -2, z: 0),
        ]
        
        for i in 0 ..< inputCoordinates.count {
            XCTAssertEqual(rotateCoordinate(inputCoordinates[i], direction: .defaultRotation.rotated90DegreesCounterClockwise), expectedCoordinates[i])
        }
    }
    
    func test_rotateCoordinate_doesNotChangeZproperty() {
        let inputCoordinates = [
            Vector(x: 2, y: -5, z: 5),
            Vector(x: 3, y: 1, z: -2),
            Vector(x: -7, y: 3, z: 4),
            Vector(x: -2, y: -4, z: -8),
        ]
        
        for inputCoordinate in inputCoordinates {
            XCTAssertEqual(rotateCoordinate(inputCoordinate, direction: .defaultRotation.rotated90DegreesClockwise).z, inputCoordinate.z)
        }
    }
    
    func test_convertWorldToScreen_takesRotationIntoAccount() {
        let rotations: [Rotation] = [.degrees45, .degrees135, .degrees225, .degrees315]
        for _ in 0 ..< 10 {
            for rotation in rotations {
                let coord = Vector.random
                let convertedCoordinate = convertWorldToScreen(coord, direction: rotation)
                
                let rotatedCoord = rotateCoordinate(coord, direction: rotation)
                let expectedCoord = convertWorldToScreen(rotatedCoord)
                
                XCTAssertEqual(convertedCoordinate, expectedCoord)
            }
        }
    }
    
    func test_convertWorldToZPosition_takesRotationIntoAccount() {
        let rotations: [Rotation] = [.degrees45, .degrees135, .degrees225, .degrees315]
        for _ in 0 ..< 10 {
            for rotation in rotations {
                let coord = Vector.random
                let convertedCoordinate = convertWorldToZPosition(coord, direction: rotation)
                
                let rotatedCoord = rotateCoordinate(coord, direction: rotation)
                let expectedCoord = convertWorldToZPosition(rotatedCoord)
                
                XCTAssertEqual(convertedCoordinate, expectedCoord)
            }
        }
    }
    
    func test_rotationWithReferenceRotation_basedOnDefaultRotation_alwaysReturnsExistingRotation() {
        for rotation in [Rotation.degrees45, Rotation.degrees135, Rotation.degrees225, Rotation.degrees315] {
            XCTAssertEqual(rotation.withReferenceRotation(.defaultRotation), rotation)
        }
    }
    
    func test_rotationWithReferenceRotation_takesReferenceRotationIntoAccount() {
        let testcases: [(lookRotation: Rotation, referenceRotation: Rotation, resultingRotation: Rotation)] = [
            (.degrees45, .degrees135, .degrees135),
            (.degrees135, .degrees135, .degrees225),
            (.degrees225, .degrees135, .degrees315),
            (.degrees315, .degrees135, .degrees45),
            (.degrees45, .degrees225, .degrees225),
            (.degrees135, .degrees225, .degrees315),
            (.degrees225, .degrees225, .degrees45),
            (.degrees315, .degrees225, .degrees135),
            (.degrees45, .degrees315, .degrees315),
            (.degrees135, .degrees315, .degrees45),
            (.degrees225, .degrees315, .degrees135),
            (.degrees315, .degrees315, .degrees225)
        ]
        
        for testcase in testcases {
            XCTAssertEqual(testcase.lookRotation.withReferenceRotation(testcase.referenceRotation), testcase.resultingRotation)
        }
    }
    
    // MARK: Animation names tests
    func test_getIdleAnimationFirstFrameNameForEntity_whenKnightIsPassedIn() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Knight", .degrees45, "Knight_Idle_45_0"),
            ("Knight", .degrees135, "Knight_Idle_135_0"),
            ("Knight", .degrees225, "Knight_Idle_225_0"),
            ("Knight", .degrees315, "Knight_Idle_315_0"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationFirstFrameNameForEntity(entity), testcase.expected)
        }
    }
    
    func test_getIdleAnimationFirstFrameNameForEntity_whenKnightIsPassedIn_andMapViewIsRotated() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Knight", .degrees45, "Knight_Idle_135_0"),
            ("Knight", .degrees135, "Knight_Idle_225_0"),
            ("Knight", .degrees225, "Knight_Idle_315_0"),
            ("Knight", .degrees315, "Knight_Idle_45_0"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationFirstFrameNameForEntity(entity, referenceRotation: .degrees135), testcase.expected)
        }
    }
    
    func test_getIdleAnimationFirstFrameNameForEntity_whenRogueIsPassedIn() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Rogue", .degrees45,  "Rogue_2H_Melee_Idle_45_0"),
            ("Rogue", .degrees135, "Rogue_2H_Melee_Idle_135_0"),
            ("Rogue", .degrees225, "Rogue_2H_Melee_Idle_225_0"),
            ("Rogue", .degrees315, "Rogue_2H_Melee_Idle_315_0"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationFirstFrameNameForEntity(entity), testcase.expected)
        }
    }
    
    func test_getIdleAnimationFirstFrameNameForEntity_whenRogueIsPassedIn_andMapViewIsRotated() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Rogue", .degrees45,  "Rogue_2H_Melee_Idle_135_0"),
            ("Rogue", .degrees135, "Rogue_2H_Melee_Idle_225_0"),
            ("Rogue", .degrees225, "Rogue_2H_Melee_Idle_315_0"),
            ("Rogue", .degrees315, "Rogue_2H_Melee_Idle_45_0"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationFirstFrameNameForEntity(entity, referenceRotation: .degrees135), testcase.expected)
        }
    }
    
    func test_getIdleAnimationNameForEntity_whenKnightIsPassedIn() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Knight", .degrees45,  "Knight_Idle_45"),
            ("Knight", .degrees135, "Knight_Idle_135"),
            ("Knight", .degrees225, "Knight_Idle_225"),
            ("Knight", .degrees315, "Knight_Idle_315"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationNameForEntity(entity), testcase.expected)
        }
    }
    
    func test_getIdleAnimationNameForEntity_whenKnightIsPassedIn_andMapViewIsRotated() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Knight", .degrees45, "Knight_Idle_135"),
            ("Knight", .degrees135, "Knight_Idle_225"),
            ("Knight", .degrees225, "Knight_Idle_315"),
            ("Knight", .degrees315, "Knight_Idle_45"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationNameForEntity(entity, referenceRotation: .degrees135), testcase.expected)
        }
    }
    
    func test_getIdleAnimationNameForEntity_whenRogueIsPassedIn() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Rogue", .degrees45,  "Rogue_2H_Melee_Idle_45"),
            ("Rogue", .degrees135, "Rogue_2H_Melee_Idle_135"),
            ("Rogue", .degrees225, "Rogue_2H_Melee_Idle_225"),
            ("Rogue", .degrees315, "Rogue_2H_Melee_Idle_315"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationNameForEntity(entity), testcase.expected)
        }
    }
    
    func test_getIdleAnimationNameForEntity_whenRogueIsPassedIn_andMapViewIsRotated() {
        let testcases: [(sprite: String, rotation: Rotation, expected: String)] = [
            ("Rogue", .degrees45,  "Rogue_2H_Melee_Idle_135"),
            ("Rogue", .degrees135, "Rogue_2H_Melee_Idle_225"),
            ("Rogue", .degrees225, "Rogue_2H_Melee_Idle_315"),
            ("Rogue", .degrees315, "Rogue_2H_Melee_Idle_45"),
        ]
        
        for testcase in testcases {
            let entity = Entity(sprite: testcase.sprite, startPosition: .zero)
            entity.rotation = testcase.rotation
            XCTAssertEqual(getIdleAnimationNameForEntity(entity, referenceRotation: .degrees135), testcase.expected)
        }
    }
}
