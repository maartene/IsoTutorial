//
//  ContentView.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject var viewModel = ViewModel(map: Map(heightMap: [
        [1,1,1,1,1],
        [1,1,1,1,1],
        [1,1,2,2,1],
        [2,4,2,3,1],
        [1,1,1,1,1],
    ]), entities: [
        Entity(sprite: "Knight", startPosition: Vector3D(x: 1, y: 1, z: 1)),
        Entity(sprite: "Knight", startPosition: Vector3D(x: 3, y: 3, z: 3)),
        Entity(sprite: "Rogue", startPosition: Vector3D(x: 4, y: 0, z: 1))
    ])
    
    let scene = GameScene()
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
            VStack {
                Spacer()
                if let selectedTile = viewModel.selectedTile {
                    Text("Selected tile: \(selectedTile)")
                        .foregroundStyle(.white)
                }
                if let selectedEntity = viewModel.selectedEntity {
                    Text("Selected entity: \(selectedEntity.sprite)")
                        .foregroundStyle(.white)
                }
                
                HStack {
                    Button("Rotate CCW") {
                        scene.rotateCCW()
                    }
                    Button("Rotate CW") {
                        scene.rotateCW()
                    }                    
                }
            }
            .padding()
        }
        .ignoresSafeArea()
        .onAppear {
            scene.viewModel = viewModel
        }
            
    }
}

#Preview {
    ContentView()
}
