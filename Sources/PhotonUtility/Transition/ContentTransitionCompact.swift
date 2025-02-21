//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/7/10.
//

import Foundation
import SwiftUI

public enum ContentTransitionCompact {
    case identity
    case opacity
    case interpolate
    case numericText(countsDown: Bool)
}

public extension Text {
    /// Apply contentTransition to a Text for Apple platforms 2022 or above.
    func contentTransitionCompact(_ transition: ContentTransitionCompact) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            let wrapped: ContentTransition
            switch transition {
            case .identity:
                wrapped = .identity
            case .opacity:
                wrapped = .opacity
            case .interpolate:
                wrapped = .interpolate
            case .numericText(let countsDown):
                wrapped = .numericText(countsDown: countsDown)
            }
            return self.contentTransition(wrapped)
        } else {
            return self
        }
    }
}
