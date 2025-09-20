//
//  View+containerCorner.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func containerCornerOffsetIfAvailable(_ edges: Edge.Set = .leading, sizeToFit: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            self.containerCornerOffset(edges, sizeToFit: sizeToFit)
        } else {
            self
        }
    }
}
