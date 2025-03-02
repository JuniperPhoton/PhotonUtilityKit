//
//  View+DynamicRange.swift
//  PhotonCamSharedUtils
//
//  Created by JuniperPhoton on 2025/1/23.
//
import SwiftUI

public extension View {
    @ViewBuilder
    func allowedDynamicRangeCompat(_ dynamicRange: DynamicRangeCompat) -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.allowedDynamicRange(dynamicRange.toImageDynamicRange)
        } else {
            self
        }
    }
}

public enum DynamicRangeCompat {
    case standard
    case constrainedHigh
    case high
    
    @available(iOS 17.0, macOS 14.0, *)
    var toImageDynamicRange: Image.DynamicRange {
        switch self {
        case .standard:
            return .standard
        case .constrainedHigh:
            return .constrainedHigh
        case .high:
            return .high
        }
    }
}
