//
//  Rotation.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 23/03/2024.
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
    
    var toVector2D: Vector2D {
        switch self {
            
        case .degrees45:
            return Vector2D(x: 1, y: 0)
        case .degrees135:
            return Vector2D(x: 0, y: 1)
        case .degrees225:
            return Vector2D(x: -1, y: 0)
        case .degrees315:
            return Vector2D(x: 0, y: -1)
        }
    }
    
    static func fromLookDirection(_ direction: Vector2D) -> Rotation? {
        
        guard direction.length > 0 else {
            return nil
        }
        
        let rotationsAndDotProducts = [
            Rotation.degrees45,
            Rotation.degrees135,
            Rotation.degrees225,
            Rotation.degrees315,
        ].map {
            let dotProduct = Vector2D.dotNormalized($0.toVector2D, direction)
            return (rotation: $0, dotProduct: dotProduct)
        }
        
        return rotationsAndDotProducts.max {
            $0.dotProduct < $1.dotProduct
        }?.rotation
    }
}
