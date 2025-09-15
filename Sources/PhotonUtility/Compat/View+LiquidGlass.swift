//
//  View+LiquidGlass.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/13/25.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func scrollEffectSoftIfAvailable(for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.scrollEdgeEffectStyle(.soft, for: edges)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func scrollEffectHardIfAvailable(for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.scrollEdgeEffectStyle(.hard, for: edges)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func safeAreaBarOrItem<ContentView: View>(
        of edge: VerticalEdge,
        @ViewBuilder content: (SafeAreaContentType) -> ContentView
    ) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.safeAreaBar(edge: edge) {
                content(.bar)
            }
        } else {
            self.safeAreaInset(edge: edge) {
                content(.bar)
            }
        }
    }
}

public enum SafeAreaContentType {
    case bar
    case inset
}

@available(iOS 16, macOS 13, tvOS 16, *)
public extension ToolbarItem {
    @ToolbarContentBuilder
    func sharedBackgroundHiddenIfAvailable() -> some ToolbarContent {
        sharedBackgroundVisibilitySettingIfAvailable(show: false)
    }
    
    @ToolbarContentBuilder
    func sharedBackgroundVisibilitySettingIfAvailable(show: Bool) -> some ToolbarContent {
        if #available(iOS 26, macOS 26, *) {
            self.sharedBackgroundVisibility(show ? .visible : .hidden)
        } else {
            self
        }
    }
}

public extension View {
    @ViewBuilder
    func liquidGlassIfAvailable(
        @ViewBuilder then: (Self) -> some View,
        @ViewBuilder fallback: (Self) -> some View
    ) -> some View {
        if #available(iOS 26, macOS 26, *) {
            then(self)
        } else {
            fallback(self)
        }
    }
    
    @ViewBuilder
    func liquidGlassIfAvailable(
        @ViewBuilder then: (Self) -> some View
    ) -> some View {
        if #available(iOS 26, macOS 26, *) {
            then(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func liquidGlassIfUnavailable(
        @ViewBuilder then: (Self) -> some View
    ) -> some View {
        if #unavailable(iOS 26, macOS 26) {
            then(self)
        } else {
            self
        }
    }
}

public extension View {
    @ViewBuilder
    func moreIconImage(inLiquidGlass: Bool = true) -> some View {
        if inLiquidGlass, #available(iOS 26, macOS 26, *) {
            Image(systemName: "ellipsis")
        } else {
            Image(systemName: "ellipsis")
                .symbolVariant(.circle.fill)
        }
    }
}

public struct MoreIconImage: View {
    public var inLiquidGlass: Bool
    
    public init(inLiquidGlass: Bool = true) {
        self.inLiquidGlass = inLiquidGlass
    }
    
    public var body: some View {
        if inLiquidGlass, #available(iOS 26, macOS 26, *) {
            Image(systemName: "ellipsis")
        } else {
            Image(systemName: "ellipsis")
                .symbolVariant(.circle.fill)
        }
    }
}
