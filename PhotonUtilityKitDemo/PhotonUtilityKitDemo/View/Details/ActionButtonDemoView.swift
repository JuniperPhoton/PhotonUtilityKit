//
//  ActionButtonDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

struct ActionButtonDemoView: View {
    @State private var isLoading = true
    
    @StateObject private var code = HighliableCode(code:
                """
                ActionButton(title: "Play", icon: "play",
                             isLoading: $isLoading)
                    .actionButtonForegroundColor(.accentColor)
                    .actionButtonBackgroundColor(.accentColor.opacity(0.1))
                """)
    
    var body: some View {
        VStack(alignment: .leading) {
            HighliableCodeView(code: code, maxHeight: 100)
            
            Text("Icon only").applySubTitle()
            
            ActionButton(icon: "play")
                .actionButtonForegroundColor(.accentColor)
                .actionButtonBackgroundColor(.accentColor.opacity(0.1))
            
            Text("Icon and text").applySubTitle()
                .padding(.top)
            
            ActionButton(title: "Play", icon: "play")
                .actionButtonForegroundColor(.accentColor)
                .actionButtonBackgroundColor(.accentColor.opacity(0.1))
            
            Text("With loading").applySubTitle()
                .padding(.top)
            
            Text("Toggle loading").asButton {
                self.isLoading.toggle()
            }
            
            VStack {
                Text("Is loading: \(String(describing: isLoading))")
                    .matchWidth(.leading)
                
                ActionButton(title: "Play", icon: "play",
                             isLoading: $isLoading)
                .matchWidth(.leading)
            }
            .actionButtonForegroundColor(.accentColor)
            .actionButtonBackgroundColor(.accentColor.opacity(0.1))
            .animation(.easeInOut, value: isLoading)
            
            Text("Stretch to width").applySubTitle()
                .actionButtonForegroundColor(.accentColor)
                .actionButtonBackgroundColor(.accentColor.opacity(0.1))
                .padding(.top)
            
            ActionButton(title: "Play", icon: "play")
                .actionButtonForegroundColor(.white)
                .actionButtonBackgroundColor(.accentColor)
                .actionButtonStretchToWidth(true)
        }
        .padding()
        .matchWidth()
        .matchHeight(.topLeading)
        .navigationTitle("ActionButton")
    }
}
