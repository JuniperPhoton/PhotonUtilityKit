//
//  View+LiquidGlass.swift
//  PhotonLegacyCompat
//
//  Created by juniperphoton on 9/13/25.
//
import SwiftUI

public var isLiquidGlassAvailable: Bool {
    if #available(iOS 26.0, macOS 26.0, *) {
        return true
    } else {
        return false
    }
}

public extension View {
    @ViewBuilder
    func liquidGlassIfAvailable(
        @ViewBuilder then: (Self) -> some View,
        @ViewBuilder fallback: (Self) -> some View
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            then(self)
        } else {
            fallback(self)
        }
    }
    
    @ViewBuilder
    func liquidGlassIfAvailable(
        @ViewBuilder then: (Self) -> some View
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            then(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func liquidGlassIfUnavailable(
        @ViewBuilder then: (Self) -> some View
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            then(self)
        } else {
            self
        }
    }
}
