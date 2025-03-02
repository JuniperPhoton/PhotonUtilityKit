//
//  View+PresentationBackground.swift
//  PhotonCamSharedUtils
//
//  Created by JuniperPhoton on 2025/2/20.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func presentationBackgroundCompat<Background: ShapeStyle>(_ background: Background) -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            self.presentationBackground(background)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func applySheetPresentationBackground() -> some View {
        self.presentationBackgroundCompat(.ultraThickMaterial)
    }
}
