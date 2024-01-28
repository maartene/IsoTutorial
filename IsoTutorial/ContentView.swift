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
                    Button("Rotate CCW") {
                        scene.rotateCCW()
                    }
                    Button("Rotate CW") {
                        scene.rotateCW()
                    }                    
                }
            }
        }
        .ignoresSafeArea()
            
    }
}

#Preview {
    ContentView()
}
