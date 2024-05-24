//
//  ContentView.swift
//  ResolutionGamesAssignment
//
//  Created by Geovanni Fuentes on 2023-06-26.
//

import SwiftUI
import Combine
import RealityKit

struct ContentView : View {
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
            .overlay {
                VStack {
                    Spacer()
                    
                    restartButton
                }
            }
    }
    
    @ViewBuilder
    private var restartButton: some View {
        Button(action: { ARSessionControl.actionSteam.send(.restartObjects) }) {
            Text("Restart")
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Material.ultraThinMaterial)
        )
        .padding()
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        return ARSessionStore.shared.arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
