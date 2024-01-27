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
    
    return worldSpacePosition.x * xOffset + worldSpacePosition.y * yOffset
    
}
