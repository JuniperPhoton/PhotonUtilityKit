//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/8/10.
//

import Foundation
import SwiftUI

@frozen
public enum HoverEffectCompact {
    case automatic
    case highlight
    case lift
    
    #if os(iOS)
    var wrappedEffect: HoverEffect {
        switch self {
        case .automatic:
            return HoverEffect.automatic
        case .highlight:
            return HoverEffect.highlight
        case .lift:
            return HoverEffect.lift
        }
    }
    #endif
}

public extension View {
    /// Compact version of ``hoverEffect``.
    /// It's available for iPad only.
    func hoverEffectCompact(_ effect: HoverEffectCompact = .automatic) -> some View {
#if os(iOS)
        self.hoverEffect(effect.wrappedEffect)
#else
        self
#endif
    }
}
