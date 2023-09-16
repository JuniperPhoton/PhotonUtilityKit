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
    /// - parameter tipContent: The instance of ``AppTipContent`` protocol
    /// - parameter enabled: Enabled or not
    /// - parameter delay: The delay measured in seconds for this tips to show
    @ViewBuilder
    func popoverTips(tipContent: any AppTipContent, enabled: Bool, delay: TimeInterval = 0.0) -> some View {
        if !enabled {
            self
        } else {
            self.modifier(PopoverTipsModifier(tipContent: tipContent, delay: delay))
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
    
    let tipContent: any AppTipContent
    let delay: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .popoverCompat(isPresented: $showTips) {
                TipsPopover(text: tipContent.text, icon: tipContent.icon)
            }
            .onReceive(tipsCenter.$scheduledNextTipContent) { output in
                print("AppTipsCenter on receive: \(type(of: output).key), current associated: \(type(of: tipContent).key)")
                if type(of: output).key == type(of: tipContent).key && output.associatedObjectKey == tipContent.associatedObjectKey {
                    tipsCenter.setCurrentDisplayingTipContent(tipContent)
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        showTips = true
                    }
                }
            }
            .onChange(of: showTips) { newValue in
                if !newValue {
                    tipsCenter.setCurrentDisplayingTipContent(EmptyAppTipContent())
                    let scheduled = tipsCenter.scheduleNextIfEmpty(setShown: true)
                    if scheduled == nil {
                        tipsCenter.resetScheduledTipContent()
                    }
                }
            }
            .onAppear {
                print("PopoverTipsModifier onAppear, tip: \(tipContent)")
            }
    }
}
