//
//  Vector2D.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 17/02/2024.
//

import Foundation

struct Vector2D { 
    let x: Int
    let y: Int
    
    static var zero: Vector2D {
        Vector2D(x: 0, y: 0)
    }
    
    static func +(lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func -(lhs: Vector2D, rhs: Vector2D) -> Vector2D {
        Vector2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func *(scalar: Int, vector: Vector2D) -> Vector2D {
        Vector2D(x: scalar * vector.x, y: scalar * vector.y)
    }
    
    var neighbours: [Vector2D] {
        [
            self + Vector2D(x: 1, y: 0),
            self + Vector2D(x: -1, y: 0),
            self + Vector2D(x: 0, y: 1),
            self + Vector2D(x: 0, y: -1),
        ]
    }
    
    var length: Double {
        sqrt(Double(x * x + y * y))
    }
    
    static func dotNormalized(_ lhs: Vector2D, _ rhs: Vector2D) -> Double {
        let lhsLength = lhs.length
        let rhsLength = rhs.length
        let xDotPart = (Double(lhs.x) / lhsLength) * (Double(rhs.x) / rhsLength)
        let yDotPart = (Double(lhs.y) / lhsLength) * (Double(rhs.y) / rhsLength)
        return xDotPart + yDotPart
    }
}

extension Vector2D: Hashable { }
