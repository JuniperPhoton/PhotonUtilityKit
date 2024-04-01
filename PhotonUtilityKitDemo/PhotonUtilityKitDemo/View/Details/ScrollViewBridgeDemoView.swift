//
//  ScrollViewBridgeDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2024/4/1.
//

import SwiftUI
import PhotonUtilityView

struct ScrollViewBridgeDemoView: View {
#if os(iOS)
    @StateObject private var controllerForPortrait = ScrollViewBridgeController()
    @StateObject private var controllerForLandscape = ScrollViewBridgeController()
#endif
    
    var body: some View {
#if os(iOS)
        VStack {
            GeometryReader { proxy in
                ScrollViewBridge(
                    controller: controllerForPortrait,
                    actualContentAspectRatio: CGSize(width: proxy.size.width * 0.9, height: proxy.size.width * 1.1),
                    scrollViewSize: CGSize(width: proxy.size.width, height: proxy.size.width)
                ) {
                    ScrollViewContentView(label: "Portrait")
                }.background(Color.gray.opacity(0.2))
            }.frame(width: 300, height: 300)
            
            Button("Reset zoom") {
                controllerForPortrait.resetZoom()
            }
            
            GeometryReader { proxy in
                ScrollViewBridge(
                    controller: controllerForLandscape,
                    actualContentAspectRatio: CGSize(width: proxy.size.width, height: proxy.size.width * 0.8),
                    scrollViewSize: CGSize(width: proxy.size.width, height: proxy.size.width)
                ) {
                    ScrollViewContentView(label: "Landscape")
                }.background(Color.gray.opacity(0.2))
            }.frame(width: 300, height: 300)
            
            Button("Scroll to top-left") {
                controllerForLandscape.requestZoom(to: CGPoint(x: 0, y: 0), scaleFactor: 3)
            }
        }.navigationTitle("ScrollViewBridge Demo")
#else
        Text("Supports iOS only.")
#endif
    }
}

private struct ScrollViewContentView: View {
    let label: String
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.red, .green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
            
            Image("SampleImage")
                .resizable()
                .scaledToFit()
            
            Text(label)
                .font(.title2)
                .foregroundStyle(.white)
                .matchParent(alignment: .topLeading)
                .padding()
        }
    }
}

#Preview {
    ScrollViewBridgeDemoView()
}
