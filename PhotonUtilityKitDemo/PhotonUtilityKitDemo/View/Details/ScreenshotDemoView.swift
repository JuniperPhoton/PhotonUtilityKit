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
    
    func takeScreenshot() {
#if os(macOS)
        self.image = AppWindowService.shared.createScreenshot(bestResolution: true)
#endif
    }
}

struct ScreenshotDemoView: View {
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
            }
            
            HighliableCodeView(code: code)
        }
        .toolbar {
            Text("Request permission").asButton {
                viewModel.requestPermission()
            }
            Text("Take screenshot").asButton {
                viewModel.takeScreenshot()
            }
        }
        .padding()
    }
}
