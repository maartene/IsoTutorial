//
//  EntityView.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 06/04/2024.
//

import SwiftUI

struct EntityView: View {
    @ObservedObject var viewModel: ViewModel
    
    var entity: Entity {
        viewModel.selectedEntity ?? Entity(sprite: "Placeholder", startPosition: .random)
    }
    
    var body: some View {
        VStack {
            Text("\(entity.sprite) (\(entity.team))")
                .font(.headline)
                .foregroundColor(.white)
            Text("\(entity.currentAction?.description ?? "Idle")")
                .foregroundColor(.red)
            Text("HP: \(entity.currentHP)/###")
                .font(.subheadline)
                .foregroundColor(.red)
            Text("MP: ###/###")
                .font(.subheadline)
                .foregroundColor(.blue)
            Text("hasActed: \(entity.hasActed)") .foregroundColor(.white)
            if viewModel.currentAction == nil && entity.hasActed == false && entity.team
                == "Player" && viewModel.battle.activeTeam == "Player" {
                HStack {
                    Button("Move") {
                        viewModel.currentAction = MoveAction(owner: entity, path: [])
                        viewModel.redraw?()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    Button("Attack") {
                        viewModel.currentAction = AttackAction(target: nil)
                        viewModel.redraw?()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    Button("Face") {
                        print("Face")
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                }
            }
        }.padding()
            .background(Color.gray.luminanceToAlpha())
            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 10)))
    }
}

#Preview {
    EntityView(viewModel: ViewModel(map: Map(), entities: []))
}
