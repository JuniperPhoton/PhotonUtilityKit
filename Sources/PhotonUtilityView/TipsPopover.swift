//
//  TipsPopover.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/8/8.
//

import SwiftUI
import Foundation

public struct TipsPopoverConfig {
    /// The preferred color scheme for the popover tips.
    /// Currently supports iOS/iPadOS only.
    public var preferredColorScheme: ColorScheme? = nil
    
    public init(preferredColorScheme: ColorScheme? = nil) {
        self.preferredColorScheme = preferredColorScheme
    }
}

public extension View {
    /// Shows popover tips if the view receives the notification from ``AppTipsController``.
    /// - parameter tipContent: The instance of ``AppTipContent`` protocol
    /// - parameter enabled: Enabled or not
    /// - parameter delay: The delay measured in seconds for this tips to show
    /// - parameter config: The configuration for the popover tips. See ``TipsPopoverConfig`` for more details.
    @ViewBuilder
    func popoverTips(
        tipContent: any AppTipContent,
        enabled: Bool,
        delay: TimeInterval = 0.0,
        config: TipsPopoverConfig = TipsPopoverConfig()
    ) -> some View {
        if !enabled {
            self
        } else {
            self.modifier(
                PopoverTipsModifier(
                    tipContent: tipContent,
                    delay: delay,
                    config: config
                )
            )
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
    let config: TipsPopoverConfig
    
    func body(content: Content) -> some View {
        content
            .popoverCompat(isPresented: $showTips, config: config) {
                if let preferredColorScheme = config.preferredColorScheme {
                    TipsPopover(text: tipContent.text, icon: tipContent.icon)
                        .colorScheme(preferredColorScheme)
                } else {
                    TipsPopover(text: tipContent.text, icon: tipContent.icon)
                }
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
                    onDismiss()
                }
            }
            .onAppear {
                print("PopoverTipsModifier onAppear, tip: \(tipContent)")
            }
            .onDisappear {
                showTips = false
                onDismiss()
            }
    }
    
    private func onDismiss() {
        tipsCenter.setCurrentDisplayingTipContent(EmptyAppTipContent())
        let scheduled = tipsCenter.scheduleNextIfEmpty(setShown: true)
        if scheduled == nil {
            tipsCenter.resetScheduledTipContent()
        }
    }
}
