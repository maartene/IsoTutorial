//
//  IsoConverter.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation

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
}

extension Vector: Equatable { }

func convertWorldToScreen(_ worldSpacePosition: Vector) -> Vector {
    let xOffset = Vector(x: 16, y: 8)
    let yOffset = Vector(x: -16, y: 8)
    let zOffset = Vector(x: 0, y: 8)
    
    return worldSpacePosition.x * xOffset + worldSpacePosition.y * yOffset + worldSpacePosition.z * zOffset
}

func convertWorldToZPosition(_ worldSpacePosition: Vector) -> Int {
    -convertWorldToScreen(worldSpacePosition).y + worldSpacePosition.z * 8 * 2
}
