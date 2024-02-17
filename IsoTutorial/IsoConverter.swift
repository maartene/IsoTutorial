//
//  IsoConverter.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation

enum Rotation: Int {
    case degrees45 = 45
    case degrees135 = 135
    case degrees225 = 225
    case degrees315 = 315
    
    static var defaultRotation: Rotation {
        .degrees45
    }
    
    var rotated90DegreesClockwise: Rotation {
        let degrees = self.rawValue
        let rotatedDegrees = (degrees + 360 - 90) % 360
        return Rotation(rawValue: rotatedDegrees)!
    }
    
    var rotated90DegreesCounterClockwise: Rotation {
        let degrees = self.rawValue
        let rotatedDegrees = (degrees + 90) % 360
        return Rotation(rawValue: rotatedDegrees)!
    }
    
    func withReferenceRotation(_ referenceRotation: Rotation) -> Rotation {
        Rotation(rawValue: (rawValue + referenceRotation.rawValue - Rotation.defaultRotation.rawValue) % 360)!
    }
}

struct Vector {
    let x: Int
    let y: Int
    let z: Int
    
    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    init(x: Int, y: Int) {
        self.init(x: x, y: y, z: 0)
    }
    
    static func +(lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func *(scalar: Int, vector: Vector) -> Vector {
        Vector(x: scalar * vector.x, y: scalar * vector.y)
    }
    
    static var random: Vector {
        Vector(x: Int.random(in: -1000...1000), y: Int.random(in: -1000...1000), z: Int.random(in: -1000...1000))
    }
    
    static var zero: Vector {
        Vector(x: 0, y: 0, z: 0)
    }
}

extension Vector: Equatable { }

func convertWorldToScreen(_ worldSpacePosition: Vector, direction: Rotation = .defaultRotation) -> Vector {
    let xOffset = Vector(x: 16, y: 8)
    let yOffset = Vector(x: -16, y: 8)
    let zOffset = Vector(x: 0, y: 8)
    
    let rotatedWorldSpacePosition = rotateCoordinate(worldSpacePosition, direction: direction)
    
    return rotatedWorldSpacePosition.x * xOffset + rotatedWorldSpacePosition.y * yOffset + rotatedWorldSpacePosition.z * zOffset
}

func convertWorldToZPosition(_ worldSpacePosition: Vector, direction: Rotation = .defaultRotation) -> Int {
    -convertWorldToScreen(worldSpacePosition, direction: direction).y + worldSpacePosition.z * 8 * 2
}

func rotateCoordinate(_ coord: Vector, direction: Rotation) -> Vector {
    switch direction {
    case .degrees45:
        return coord
    case .degrees225:
        return Vector(x: -coord.x, y: -coord.y, z: coord.z)
    case .degrees315:
        return Vector(x: coord.y, y: -coord.x, z: coord.z)
    case .degrees135:
        return Vector(x: -coord.y, y: coord.x, z: coord.z)
    }
}

let spriteAnimationMap = [
    "Rogue":
        [
            "Idle": "2H_Melee_Idle"
        ]
]

func getIdleAnimationFirstFrameNameForEntity(_ entity: Entity, referenceRotation: Rotation = .defaultRotation) -> String {
    getIdleAnimationNameForEntity(entity, referenceRotation: referenceRotation) + "_0"
}

func getIdleAnimationNameForEntity(_ entity: Entity, referenceRotation: Rotation = .defaultRotation) -> String {
    let animationName = spriteAnimationMap[entity.sprite]?["Idle"] ?? "Idle"
    let viewRotation = entity.rotation.withReferenceRotation(referenceRotation)
    return "\(entity.sprite)_\(animationName)_\(viewRotation.rawValue)"
}
