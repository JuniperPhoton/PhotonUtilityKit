//
//  ScrollViewBridgeDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2024/4/1.
//

import SwiftUI
import PhotonUtilityView

struct ScrollViewBridgeDemoView: View {
    var body: some View {
#if os(iOS)
        VStack {
            GeometryReader { proxy in
                ScrollViewBridge(
                    actualContentAspectRatio: CGSize(width: proxy.size.width * 0.9, height: proxy.size.width * 1.1),
                    scrollViewSize: CGSize(width: proxy.size.width, height: proxy.size.width)
                ) {
                    ZStack {
                        LinearGradient(colors: [.red, .green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        
                        Image("SampleImage")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Portrait")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .matchParent(alignment: .topLeading)
                            .padding()
                    }
                }
                    .background(Color.gray.opacity(0.2))
            }.frame(width: 300, height: 300)
            
            GeometryReader { proxy in
                ScrollViewBridge(
                    actualContentAspectRatio: CGSize(width: proxy.size.width, height: proxy.size.width * 0.8),
                    scrollViewSize: CGSize(width: proxy.size.width, height: proxy.size.width)
                ) {
                    ZStack {
                        LinearGradient(colors: [.red, .green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        
                        Image("SampleImage")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Landscape")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .matchParent(alignment: .topLeading)
                            .padding()
                    }
                }
                    .background(Color.gray.opacity(0.2))
            }.frame(width: 300, height: 300)
        }.navigationTitle("ScrollViewBridge Demo")
#else
        Text("Supports iOS only.")
#endif
    }
}

#Preview {
    ScrollViewBridgeDemoView()
}
