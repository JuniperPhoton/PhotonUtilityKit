//
//  View+SafeAreaContent.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func safeAreaBarOrItem<ContentView: View>(
        of edge: VerticalEdge,
        @ViewBuilder content: (SafeAreaContentType) -> ContentView
    ) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.safeAreaBar(edge: edge) {
                content(.bar)
            }
        } else {
            self.safeAreaInset(edge: edge) {
                content(.inset)
            }
        }
    }
}

public enum SafeAreaContentType {
    case bar
    case inset
}
