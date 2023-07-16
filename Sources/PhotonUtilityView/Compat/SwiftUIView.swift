//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI

public enum SearchFieldPlacementCompact {
    case automatic
    case sidebar
    case toolbar
    
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    var wrapped: SearchFieldPlacement {
        switch self {
#if !os(tvOS)
        case .automatic:
            return .automatic
        case .sidebar:
            return .sidebar
        case .toolbar:
            return .toolbar
#endif
        default:
            return .automatic
        }
    }
}

public extension View {
    @ViewBuilder
    func searchableCompact(text: Binding<String>,
                           placement: SearchFieldPlacementCompact = .automatic,
                           prompt: Text? = nil) -> some View {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            self.searchable(text: text, placement: placement.wrapped, prompt: prompt)
        } else {
            self
        }
    }
}
