//
//  TipsDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/8/20.
//

import SwiftUI
import PhotonUtilityView

struct TipsDemoView: View {
    @ObservedObject private var tipsCenter = AppTipsCenter.shared
    @StateObject private var toast = AppToast()
    
    @State private var code = HighliableCode(code: """
    struct ToolbarButtonTip: AppTipContent {
        static let key = "ToolbarButtonTip"
        
        var text: String = "A button from toolbar"
        var icon: String? = "exclamationmark.bubble.fill"
        var associatedObjectKey: String
        
        init(associatedObjectKey: String) {
            self.associatedObjectKey = associatedObjectKey
        }
    }
    
    ToolbarItem(placement: .navigation) {
        Image(systemName: "gear").asButton {
            toast.showToast("Press gear button")
        }.popoverTips(tipContent: ToolbarButtonTip(associatedObjectKey: "first"), enabled: true)
    }
    """)
        
    var body: some View {
        VStack {
            Text("Show tips manually").asButton {
                AppTipsCenter.shared.enqueueTip(ToolbarButtonTip(associatedObjectKey: "first"))
            }.popoverTips(tipContent: ManuallyPressButton(), enabled: true)
            
            HighliableCodeView(code: code, maxHeight: 400)
                .padding(.horizontal)
        }
        .withToast(toast)
        .navigationTitle("Tips demo")
        .disabled(!tipsCenter.displayingTipContent.isEmpty)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Image(systemName: "gear").asButton {
                    toast.showToast("Press gear button")
                }.popoverTips(tipContent: ToolbarButtonTip(associatedObjectKey: "first"), enabled: true)
            }
            ToolbarItem(placement: .primaryAction) {
                Image(systemName: "mic.fill").asButton {
                    toast.showToast("Press mic button")
                }.popoverTips(tipContent: ToolbarButtonTip(associatedObjectKey: "primary"), enabled: true)
            }
        }
        .onAppear {
            AppTipsPreference.shared.register(tips: ToolbarButtonTip.self, ManuallyPressButton.self)
            AppTipsCenter.shared.enqueueTip(ToolbarButtonTip(associatedObjectKey: "primary"))
            AppTipsCenter.shared.enqueueTip(ManuallyPressButton())
        }
        .environmentObject(tipsCenter)
    }
}

struct ManuallyPressButton: AppTipContent {
    static let key = "ManuallyPressButton"
    var text: String = "You can press this button to show tip manually."
    var icon: String? = nil
    var associatedObjectKey: String = ManuallyPressButton.key
}

struct ToolbarButtonTip: AppTipContent {
    static let key = "ToolbarButtonTip"
    
    var text: String = "A button from toolbar"
    var icon: String? = "exclamationmark.bubble.fill"
    var associatedObjectKey: String
    
    init(associatedObjectKey: String) {
        self.associatedObjectKey = associatedObjectKey
    }
}
