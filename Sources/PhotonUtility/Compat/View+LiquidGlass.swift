//
//  View+LiquidGlass.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/13/25.
//
import SwiftUI

public var isLiquidGlassAvailable: Bool {
    if #available(iOS 26, macOS 26, *) {
        return true
    } else {
        return false
    }
}

public extension View {
    @ViewBuilder
    func applyGlassButtonStyleIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func applyGlassProminentButtonStyleIfAvailable() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self
        }
    }
}

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
    
    @ViewBuilder
    func applyVariantToFallbacks(_ symbolVariant: SymbolVariants) -> some View {
        if #available(iOS 26, macOS 26, *) {
            self.fontWeight(.regular)
        } else {
            self.symbolVariant(symbolVariant)
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
