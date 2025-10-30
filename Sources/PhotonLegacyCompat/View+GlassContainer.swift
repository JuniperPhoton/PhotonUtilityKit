//
//  View+GlassContainer.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

public struct GlassContainerIfAvailable<ContentView: View>: View {
    public var spacing: CGFloat?
    @ViewBuilder public var content: () -> ContentView
    
    public init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> ContentView) {
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else {
            content()
        }
    }
}

public extension View {
    @ViewBuilder
    func wrapInGlassContainerIfAvailable(spacing: CGFloat? = nil, enableForiOS26_0Only: Bool = false) -> some View {
        if #available(iOS 26.1, *) {
            if enableForiOS26_0Only {
                self
            } else {
                GlassContainerIfAvailable(spacing: spacing) {
                    self
                }
            }
        } else if #available(iOS 26.0, *) {
            GlassContainerIfAvailable(spacing: spacing) {
                self
            }
        } else {
            self
        }
    }
}
