//
//  AppAnimation.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/18.
//

import Foundation
import SwiftUI

public extension Binding {
    /// Apply ``withEaseOutAnimation(duration:_:onEnd:onEndDelay:_:)`` to a ``Binding``.
    @available(*, deprecated, message: "Recommend to use default animation.")
    func easeOutAnimation() -> Binding {
        self.animation(.easeOut)
    }
}

/// Returns the result of recomputing the view's body with the provided
/// animation.
///
/// The animation is fixed to using eastOut curve. And you can custom the ``duration``, ``delay`` of this animation.
/// To perform task on the animation ended, you pass the ``onEnd`` to achieve that. You use the ``onEndDelay`` to control how ``onEnd`` will be invoked
/// after the original animation started.
///
/// If you want to animate value from one to other, then from the other to another one, you can use the ``animate(value:from:to:duration:_:interval:)`` for convenience.
@available(*, deprecated, message: "Recommend to use default animation.")
public func withEaseOutAnimation<Result>(duration: TimeInterval = 0.3,
                                         _ delay: TimeInterval = 0.0,
                                         onEnd: (() -> Void)? = nil,
                                         onEndDelay: TimeInterval = 0.3,
                                         _ body: () throws -> Result) -> Result? {
    let result = try? withAnimation(Animation.easeOut(duration: duration).delay(delay)) {
        try body()
    }
    if let onEnd = onEnd {
        // TODO For iOS 17, macOS 14.0, use the new withAnimation to invoke on end.
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + duration + delay + onEndDelay) {
            withAnimation(Animation.easeOut(duration: duration).delay(delay)) {
                onEnd()
            }
        }
    }
    return result
}

/// Returns the result of recomputing the view's body with the provided
/// animation.
///
/// The animation is fixed to using ``default`` curve. And you can custom the ``delay`` of this animation.
/// To perform task on the animation ended, you pass the ``onEnd`` to achieve that.
/// You use the ``onEndDelay`` to control how ``onEnd`` will be invoked
/// after the original animation started.
///
/// If you want to animate value from one to other, then from the other to another one,
/// you can use the ``animate(value:from:to:duration:_:interval:)`` for convenience.
public func withDefaultAnimation<Result>(_ delay: TimeInterval = 0.0,
                                         onEnd: (() -> Void)? = nil,
                                         onEndDelay: TimeInterval = 0.3,
                                         _ body: () throws -> Result) -> Result? {
    let result = try? withAnimation(Animation.default.delay(delay)) {
        try body()
    }
    if let onEnd = onEnd {
        // TODO For iOS 17, macOS 14.0, use the new withAnimation to invoke on end.
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + delay + onEndDelay) {
            withAnimation(Animation.default.delay(delay)) {
                onEnd()
            }
        }
    }
    return result
}

/// Animate the binding ``value`` from the ``from`` value to ``to`` value and wait for ``internal`` and reverse back.
///
/// You can custom the animation by setting the ``duration`` and ``delay``.
public func animateBackForth<T>(value: Binding<T>,
                                from: T, to: T?,
                                _ delay: TimeInterval = 0.0,
                                interval: TimeInterval = 1.0) {
    withDefaultAnimation(delay, onEnd: {
        if to != nil {
            value.wrappedValue = to!
        }
    }, onEndDelay: interval) {
        value.wrappedValue = from
    }
}
