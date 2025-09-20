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
        if #available(iOS 26, macOS 26, *) {
            GlassEffectContainer(spacing: spacing, content: content)
        } else {
            content()
        }
    }
}

public extension View {
    func wrapInGlassContainerIfAvailable(spacing: CGFloat? = nil) -> some View {
        GlassContainerIfAvailable(spacing: spacing) {
            self
        }
    }
}
