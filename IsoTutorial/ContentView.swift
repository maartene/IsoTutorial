//
//  ContentView.swift
//  IsoTutorial
//
//  Created by Maarten Engels on 27/01/2024.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteView(scene: GameScene())
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
