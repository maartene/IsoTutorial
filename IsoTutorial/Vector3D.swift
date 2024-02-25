//
//  Vector3D.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 17/02/2024.
//

import Foundation

struct Vector3D {
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
    
    static func +(lhs: Vector3D, rhs: Vector3D) -> Vector3D {
        Vector3D(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func *(scalar: Int, vector: Vector3D) -> Vector3D {
        Vector3D(x: scalar * vector.x, y: scalar * vector.y)
    }
    
    static var random: Vector3D {
        Vector3D(x: Int.random(in: -1000...1000), y: Int.random(in: -1000...1000), z: Int.random(in: -1000...1000))
    }
    
    static var zero: Vector3D {
        Vector3D(x: 0, y: 0, z: 0)
    }
    
    var xy: Vector2D {
        Vector2D(x: x, y: y)
    }
}

extension Vector3D: Equatable { }
