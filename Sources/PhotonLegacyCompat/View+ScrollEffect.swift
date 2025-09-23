//
//  View+ScrollEffect.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func scrollEffectSoftIfAvailable(for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.scrollEdgeEffectStyle(.soft, for: edges)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func scrollEffectHardIfAvailable(for edges: Edge.Set = .all) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.scrollEdgeEffectStyle(.hard, for: edges)
        } else {
            self
        }
    }
}
