//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/19.
//

import SwiftUI

public enum ControlSizeCompat {
    case mini
    case small
    case regular
    case large
    
#if !os(tvOS)
    var wrapped: ControlSize {
        switch self {
        case .mini:
            return .mini
        case .small:
            return .small
        case .regular:
            return .regular
        case .large:
            return .large
        }
    }
#endif
}

public extension View {
    @ViewBuilder
    func controlSizeCompat(_ size: ControlSizeCompat) -> some View {
        #if os(tvOS)
        self
        #else
        self.controlSize(size.wrapped)
        #endif
    }
}
