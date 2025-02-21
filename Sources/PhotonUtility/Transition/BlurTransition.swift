//
//  BlurTransition.swift
//  PhotonCam
//
//  Created by JuniperPhoton on 2025/2/3.
//
import SwiftUI

@available(iOS 17.0, *)
public struct BlurTransition: Transition {
    var transitionRadius: CGFloat
    
    public init(transitionRadius: CGFloat) {
        self.transitionRadius = transitionRadius
    }
    
    public func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .blur(radius: radius(of: phase))
    }
    
    private func radius(of phase: TransitionPhase) -> CGFloat {
        switch phase {
        case .identity:
            return 0
        case .willAppear:
            return transitionRadius
        case .didDisappear:
            return transitionRadius
        }
    }
}

public extension AnyTransition {
    /// Get the blur transition on iOS 17 and macOS 14 or later, otherwise, return the identity transition.
    /// - parameter radius: The radius of the blur effect.
    static func blurCompat(radius: CGFloat = 12) -> AnyTransition {
        if #available(iOS 17, macOS 14, *) {
            AnyTransition(BlurTransition(transitionRadius: radius))
        } else {
            AnyTransition.identity
        }
    }
}
