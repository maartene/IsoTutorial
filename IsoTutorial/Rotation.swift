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
    
    static func fromLookDirection(_ direction: Vector2D) -> Rotation? {
        switch direction {
        case Vector2D(x: 1, y: 0):
            return .degrees45
        case Vector2D(x: 0, y: 1):
            return .degrees135
        case Vector2D(x: -1, y: 0):
            return .degrees225
        case Vector2D(x: 0, y: -1):
            return .degrees315
        default:
            return nil
        }
    }
}
