//
//  GlassMenuButtonStyle.swift
//  PhotonCamViews
//
//  Created by juniperphoton on 10/30/25.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func applyGlassMenuButtonStyleIfAvailable<S: Shape>(padding: CGFloat, shape: S, tint: Color? = nil) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.buttonStyle(GlassMenuButtonStyle(padding: padding, shape: shape, glass: .regular.interactive().tint(tint)))
        } else {
            self
        }
    }
    
    @ViewBuilder
    func applyGlassMenuButtonStyleIfAvailable<S: Shape>(padding: EdgeInsets, shape: S, tint: Color? = nil) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.buttonStyle(GlassMenuButtonStyle(padding: padding, shape: shape, glass: .regular.interactive().tint(tint)))
        } else {
            self
        }
    }
}

@available(iOS 26.0, macOS 26.0, *)
public struct GlassMenuButtonStyle<S: Shape>: ButtonStyle {
    var padding: EdgeInsets
    var glass: Glass
    var shape: S
    
    public init(padding: EdgeInsets, shape: S, glass: Glass) {
        self.padding = padding
        self.glass = glass
        self.shape = shape
    }
    
    public init(padding: CGFloat, shape: S, glass: Glass) {
        self.init(padding: .createUnified(inset: padding), shape: shape, glass: glass)
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(padding)
            .contentShape(shape)
            .glassEffect(glass, in: shape)
    }
}
