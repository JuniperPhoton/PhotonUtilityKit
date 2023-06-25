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
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Icon only").applySubTitle()
            
            ActionButton(icon: "play",
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)))
            
            Text("Icon and text").applySubTitle()
                .padding(.top)
            ActionButton(title: "Play", icon: "play",
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)))
            
            Text("With loading").applySubTitle()
                .padding(.top)
            
            Text("Toggle loading").asButton {
                self.isLoading.toggle()
            }
            
            ActionButton(title: "Play", icon: "play",
                         isLoading: $isLoading,
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)))
            .animation(.easeInOut, value: isLoading)
            
            Text("Stretch to width").applySubTitle()
                .padding(.top)
            
            ActionButton(title: "Play", icon: "play",
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)),
                         frameConfigration: .init(true))
        }
        .padding()
        .matchWidth()
        .navigationTitle("ActionButton")
    }
}
