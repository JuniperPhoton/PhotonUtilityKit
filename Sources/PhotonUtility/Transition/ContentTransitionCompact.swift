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
    }
}
