//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/2/14.
//

import SwiftUI

public extension View {
    func focusSectionCompat() -> some View {
#if os(tvOS)
        self.focusSection()
#else
        self
#endif
    }
    
    func focusScopeCompat(_ namespace: Namespace.ID) -> some View {
#if os(tvOS)
        self.focusScope(namespace)
#else
        self
#endif
    }
    
    func applyFocusStyleForTV(onFocusChanged: ((Bool) -> Void)? = nil) -> some View {
#if os(tvOS)
        self.modifier(FocusStyleForTV(onFocusChanged: onFocusChanged))
#else
        self
#endif
    }
    
    func onTapGestureCompact(perform: @escaping () -> Void) -> some View {
#if !os(tvOS)
        self.onTapGesture(perform: perform)
#else
        self
#endif
    }
}

public extension View {
    @ViewBuilder
    func monospacedDigitCompat() -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
            self.monospacedDigit()
        } else {
            self
        }
    }
}

public extension View {
    /// Set the navigation bar title's display mode to either inline or not.
    func navigationBarTitleDisplayModeCompat(inline: Bool) -> some View {
#if canImport(UIKit)
        self.navigationBarTitleDisplayMode(inline ? .inline : .automatic)
#else
        self
#endif
    }
    
    /// Hide the status bar or not.
    func statusBarHiddenCompat(hidden: Bool = true) -> some View {
#if canImport(UIKit)
        self.statusBarHidden(hidden)
#else
        self
#endif
    }
}
