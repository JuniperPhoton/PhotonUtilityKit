//
//  FullscreenContentDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

struct FullscreenContentDemoView: View {
    @StateObject private var fullscreenPresentation = FullscreenPresentation()

    var body: some View {
        ZStack {
            VStack {
                Text(
            """
            Show full-screen content in a specified view.
            
            You can use BottomSheetView as a parent view to display a sheet-based view.
            
            On iOS, BottomSheetView appears as a bottom sheet with a swipe-down gesture, while on macOS, it appears in the center.
            """
                )
                .matchWidth(.leading)
                .padding(.bottom)
                
                VStack(spacing: 20) {
                    Text("Bottom sheet").asButton {
                        let view = BottomSheetView(backgroundColor: .white) {
                            VStack {
                                Text("Bottom sheet title")
                                    .font(.title.bold())
                                    .padding(.bottom)
                                Text("On iOS and iPadOS, you can swipe down to dismiss.")
                                    .multilineTextAlignment(.center)
                            }.matchHeight(.top).frame(maxHeight: 200)
                        }
                        
                        fullscreenPresentation.present(view: view)
                    }.matchWidth(.leading)
                    
                    Text("Custom").asButton {
                        let view = VStack {
                            Text("Custom title")
                                .font(.title.bold())
                                .padding(.bottom)
                            Text("A custom view content. Tap to dismiss.")
                                .multilineTextAlignment(.center)
                        }.matchParent()
                        #if os(iOS)
                            .background(.thinMaterial)
                        #else
                            .background(Color.black.opacity(0.5))
                        #endif
                            .onTapGesture {
                                fullscreenPresentation.dismissAll()
                            }
                        
                        fullscreenPresentation.present(view: view)
                    }.matchWidth(.leading)
                }
            }
            .matchParent(alignment: .topLeading)
            .padding()
            
            fullscreenContent()
        }
        .navigationTitle("Fullscreen content")
        .environmentObject(fullscreenPresentation)
    }
    
    @ViewBuilder
    private func fullscreenContent() -> some View {
        ZStack {
            if let view = fullscreenPresentation.presentedView {
                ZStack {
                    AnyView(view)
                }.matchParent().transition(fullscreenPresentation.transition)
                    .onDisappear {
                        fullscreenPresentation.invokeOnDismiss()
                    }
            }
        }.transaction { current in
            if let override = fullscreenPresentation.transcation {
                current = override
            }
        }
    }
}
