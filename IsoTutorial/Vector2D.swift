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
    
}

extension Vector2D: Hashable { }
