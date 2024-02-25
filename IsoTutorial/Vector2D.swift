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
    
    static func *(scalar: Int, vector: Vector2D) -> Vector2D {
        Vector2D(x: scalar * vector.x, y: scalar * vector.y)
    }
    
}

extension Vector2D: Hashable { }
