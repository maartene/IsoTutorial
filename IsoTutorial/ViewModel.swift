//
//  ViewModel.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 01/04/2024.
//

import Foundation
import Combine

final class ViewModel: ObservableObject {
    @Published var selectedTile: Vector3D?
    @Published var selectedEntity: Entity?
    
    let map: Map
    let entities: [Entity]
    
    init(map: Map, entities: [Entity]) {
        self.map = map
        self.entities = entities
    }
    
    func clickTile(_ tile: Vector3D) {
        selectedTile = nil
        selectedEntity = nil
        
        if map.tiles.keys.contains(tile.xy) {
            selectedTile = tile
        }
        
        if let entity = entities.first(where: { $0.position == tile }) {
            selectedEntity = entity
        }
    }
}
