//
//  TipsPopover.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/8/8.
//

import SwiftUI
import Foundation

public extension View {
    /// Shows popover tips if the view receives the notifiaction from ``AppTipsContoller``.
    /// - parameter tipKey: The instance of ``AppTipKey`` protocol
    /// - parameter enabled: Enabled or not
    /// - parameter delay: The delay measured in seconds for this tips to show
    @ViewBuilder
    func popoverTips(tipKey: any AppTipContent, enabled: Bool, delay: TimeInterval = 0.0) -> some View {
        if !enabled {
            self
        } else {
            self.modifier(PopoverTipsModifier(tipKey: tipKey, delay: delay))
        }
    }
}

private struct TipsPopover: View {
    let text: String
    var icon: String?
    
    var body: some View {
        VStack {
            if let icon = icon {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            Text(LocalizedStringKey(text))
                .multilineTextAlignment(.center)
        }.padding()
#if os(iOS)
            .frame(maxWidth: 300)
#else
            .frame(width: 300)
#endif
    }
}

private struct PopoverTipsModifier: ViewModifier {
    @EnvironmentObject private var tipsCenter: AppTipsCenter
    @State private var showTips = false
    
    let tipKey: any AppTipContent
    let delay: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .popoverCompat(isPresented: $showTips) {
                TipsPopover(text: tipKey.text, icon: tipKey.icon)
            }
            .onReceive(tipsCenter.$currentTipContent) { output in
                print("AppTipsCenter on receive changed \(type(of: output).key), current is \(type(of: tipKey).key)")
                if type(of: output).key == type(of: tipKey).key && output.associatedObjectKey == tipKey.associatedObjectKey {
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        showTips = true
                    }
                }
            }
            .onChange(of: showTips) { newValue in
                if !newValue {
                    tipsCenter.resetToEmpty()
                    tipsCenter.showNextIfEmpty(setShown: true)
                }
            }
    }
}
