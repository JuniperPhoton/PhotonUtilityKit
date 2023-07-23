//
//  ScreenshotDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

class ScreenshotDemoViewModel: ObservableObject {
    @Published var image: CGImage? = nil
    
    func requestPermission() {
#if os(macOS)
        AppWindowService.shared.requestScreenCaptureAccess()
#endif
    }
    
    @MainActor
    func takeScreenshot() async {
#if os(macOS)
        self.image = await AppWindowService.shared.createScreenshot(bestResolution: true)
#endif
    }
}

struct ScreenshotDemoView: View {
#if os(macOS)
    @StateObject private var viewModel = ScreenshotDemoViewModel()
    @State private var code = HighliableCode(code:
            """
            func requestPermission() {
               AppWindowService.shared.requestScreenCaptureAccess()
            }
            
            func takeScreenshot() {
               self.image = AppWindowService.shared.createScreenshot(bestResolution: true)
            }
            """)
    
    var body: some View {
        VStack {
            if let image = viewModel.image {
                Image(image, scale: 1.0, label: Text(""))
                    .resizable()
                    .scaledToFit()
                    .matchWidth(.leading)
            }
            
            HighliableCodeView(code: code)
        }
        .matchParent(alignment: .topLeading)
        .toolbar {
            Text("Request permission").asButton {
                viewModel.requestPermission()
            }
            Text("Take screenshot").asButton {
                Task {
                    await viewModel.takeScreenshot()
                }
            }
        }
        .padding()
    }
#else
    var body: some View {
        Text("Not supported")
    }
#endif
}
