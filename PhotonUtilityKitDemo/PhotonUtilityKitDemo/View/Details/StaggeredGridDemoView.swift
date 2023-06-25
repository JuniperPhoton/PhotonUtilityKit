//
//  StaggeredGridDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView
import PhotonUtilityLayout

struct StaggeredGridDemoView: View {
    @State private var code = HighliableCode(code: """
    StaggeredGrid {
        StaggeredGridContentView(text: "Fish")
        StaggeredGridContentView(text: "Gloomy")
        StaggeredGridContentView(text: "Clutter up")
        StaggeredGridContentView(text: "Poggy")
        StaggeredGridContentView(text: "Rattled")
        StaggeredGridContentView(text: "Fuss")
        StaggeredGridContentView(text: "Cultivate")
    }
    """)
    
    var body: some View {
        VStack {
            Text("StaggeredGrid supports iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0 and above. Try to resize the window to see animations.")
                .padding(.horizontal)
                .matchWidth(.leading)
            
            HighliableCodeView(code: code).padding()

            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                StaggeredGrid {
                    StaggeredGridContentView(text: "Fish")
                    StaggeredGridContentView(text: "Gloomy")
                    StaggeredGridContentView(text: "Clutter up")
                    StaggeredGridContentView(text: "Poggy")
                    StaggeredGridContentView(text: "Rattled")
                    StaggeredGridContentView(text: "Fuss")
                    StaggeredGridContentView(text: "Cultivate")
                }
                .matchHeight(.top).padding(.horizontal)
            }
        }
        .navigationTitle("Staggered Grid")
    }
}

struct StaggeredGridContentView: View {
    let text: String
    
    @State private var clicked = false
    
    var body: some View {
        Text("#\(text)\(clicked ? " Clicked!" : "")")
            .font(.title2.bold())
            .foregroundColor(clicked ? .white : Color.accentColor)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.accentColor.opacity(clicked ? 1.0 : 0.1)))
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .asPlainButton {
                withAnimation {
                    clicked.toggle()
                }
            }
    }
}
