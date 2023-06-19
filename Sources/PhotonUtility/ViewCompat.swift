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
