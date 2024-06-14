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
        Entity(sprite: "Knight", startPosition: Vector3D(x: 1, y: 1, z: 1), range: 3, maxHeightDifference: 1, team: "AI"),
        Entity(sprite: "Knight", startPosition: Vector3D(x: 3, y: 3, z: 3), range: 3, maxHeightDifference: 1, team: "AI"),
        Entity(sprite: "Rogue", startPosition: Vector3D(x: 4, y: 0, z: 1), range: 4, attackRange: 3, team: "Player")
    ])
    
    @State var updateCount = 0
    
    let scene = GameScene()
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
            
            Color.green
                .opacity(0.0001) // cheesy hack to create an interactable, 'invisible' view.
                .onTapGesture { screenCoord in
                    scene.processTap(at: screenCoord)
                }
            
            VStack {
                Text("State: \(viewModel.battle.state)")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("Current team: \(viewModel.battle.activeTeam)")
                    .foregroundStyle(.white)
                if viewModel.battle.activeTeam != "Player" {
                    Button("Let enemies act") {
                        for entity in viewModel.entities.filter({ $0.team != "Player" }) {
                            entity.currentAction = DummyAction()
                        }
                        viewModel.redraw?()
                    }.buttonStyle(BorderedProminentButtonStyle())
                }
                HStack {
                    Spacer()
                    if  viewModel.selectedEntity != nil {
                        EntityView(viewModel: viewModel)
                    }
                }
                if let currentAction = viewModel.currentAction, currentAction.canComplete {
                    Button("Execute \(currentAction.description)") {
                        viewModel.commitAction()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
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
                    Button("Zoom Out", systemImage: "minus.magnifyingglass") {
                        scene.zoomOut()
                    }
                    .font(.largeTitle)
                    .labelStyle(.iconOnly)
                    .padding()
                    
                    Button("Zoom In", systemImage: "plus.magnifyingglass") {
                        scene.zoomIn()
                    }.font(.largeTitle)
                    .labelStyle(.iconOnly)
                    .padding()
                    Button("Rotate Counter Clockwise", systemImage: "arrow.counterclockwise") {
                        scene.rotateCCW()
                    }
                    .font(.largeTitle)
                    .labelStyle(.iconOnly)
                    .padding()
                    
                    Button("Rotate Clockwise", systemImage: "arrow.clockwise") {
                        scene.rotateCW()
                    }
                    .font(.largeTitle)
                        .labelStyle(.iconOnly)
                        .padding()
                }
            }
            .padding()
        }
        .disabled(viewModel.isBusy)
        .ignoresSafeArea()
        .onAppear {
            scene.viewModel = viewModel
        }
            
    }
    
}

#Preview {
    ContentView()
}
