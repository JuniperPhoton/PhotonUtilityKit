//
//  View+Symbol.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func moreIconImage(inLiquidGlass: Bool = true) -> some View {
        if inLiquidGlass, #available(iOS 26.0, macOS 26.0, *) {
            Image(systemName: "ellipsis")
        } else {
            Image(systemName: "ellipsis")
                .symbolVariant(.circle.fill)
        }
    }
    
    @ViewBuilder
    func applyVariantToFallbacks(_ symbolVariant: SymbolVariants) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
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
        if inLiquidGlass, #available(iOS 26.0, macOS 26.0, *) {
            Image(systemName: "ellipsis")
        } else {
            Image(systemName: "ellipsis")
                .symbolVariant(.circle.fill)
        }
    }
}
