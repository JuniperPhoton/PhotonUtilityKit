//
//  Untitled.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

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
