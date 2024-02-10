//
//  ContentView.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    let scene = GameScene()
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
            VStack {
                Spacer()
                HStack {
                    Button("Rotate Knight CCW") {
                        scene.rotateKnightCCW()
                    }
                    Button("Rotate Knight CW") {
                        scene.rotateKnightCW()
                    }
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
            
    }
}

#Preview {
    ContentView()
}
