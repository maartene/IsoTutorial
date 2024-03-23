//
//  IsoConverter.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import Foundation

func convertWorldToScreen(_ worldSpacePosition: Vector3D, direction: Rotation = .defaultRotation) -> Vector2D {
    let xOffset = Vector2D(x: 16, y: 8)
    let yOffset = Vector2D(x: -16, y: 8)
    let zOffset = Vector2D(x: 0, y: 8)
    
    let rotatedWorldSpacePosition = rotateCoordinate(worldSpacePosition, direction: direction)
    
    return rotatedWorldSpacePosition.x * xOffset + rotatedWorldSpacePosition.y * yOffset + rotatedWorldSpacePosition.z * zOffset
}

func convertWorldToZPosition(_ worldSpacePosition: Vector3D, direction: Rotation = .defaultRotation) -> Int {
    -convertWorldToScreen(worldSpacePosition, direction: direction).y + worldSpacePosition.z * 8 * 2
}

func rotateCoordinate(_ coord: Vector3D, direction: Rotation) -> Vector3D {
    switch direction {
    case .degrees45:
        return coord
    case .degrees225:
        return Vector3D(x: -coord.x, y: -coord.y, z: coord.z)
    case .degrees315:
        return Vector3D(x: coord.y, y: -coord.x, z: coord.z)
    case .degrees135:
        return Vector3D(x: -coord.y, y: coord.x, z: coord.z)
    }
}

let spriteAnimationMap = [
    "Knight": [
        "Walk": "Walking_B"
    ],
    "Rogue":
        [
            "Idle": "2H_Melee_Idle",
            "Walk": "Walking_C"
        ]
]

func getIdleAnimationFirstFrameNameForEntity(_ entity: Entity, referenceRotation: Rotation = .defaultRotation) -> String {
    getAnimationNameForEntity(entity, animation: "Idle", referenceRotation: referenceRotation) + "_0"
}

func getAnimationNameForEntity(_ entity: Entity, animation: String, referenceRotation: Rotation = .defaultRotation) -> String {
    let animationName = spriteAnimationMap[entity.sprite]?[animation] ?? "Idle"
    let viewRotation = entity.rotation.withReferenceRotation(referenceRotation)
    return "\(entity.sprite)_\(animationName)_\(viewRotation.rawValue)"
}
