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
    @Published var currentAction: Action?
    
    let map: Map
    let entities: [Entity]
    var redraw: (() -> Void)?
    
    init(map: Map, entities: [Entity]) {
        self.map = map
        self.entities = entities
    }
    
    func clickTile(_ tile: Vector3D) {
        selectedTile = nil
        
        
        if map.tiles.keys.contains(tile.xy) {
            selectedTile = tile
        }
        
        if let currentAction = currentAction {
            if let selectedTile, let selectedEntity {
                let action = type(of: currentAction)
                    .make(in: map, for: selectedEntity, targetting: selectedTile)
                self.currentAction = action
            }
        } else {
            selectedEntity = nil
            if let entity = entities.first(where: { $0.position == tile }) {
                selectedEntity = entity
            }
        }
    }
    
    func commitAction() {
        selectedEntity?.currentAction = currentAction
        currentAction = nil
        redraw?()
    }
}
