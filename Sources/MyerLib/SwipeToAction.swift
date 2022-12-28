//
//  File.swift
//  
//
//  Created by Photon Juniper on 2022/12/29.
//

import Foundation
import SwiftUI

/// A modifier to support swipe to perform an action of a view.
public struct SwipeToAction: ViewModifier {
    public enum Axis {
        case leadingToTrailing
        case trailingToLeading
        case both
    }
    
    private(set) var thresholdToAction: CGFloat
    private(set) var onAction: (Axis) -> Bool
    private(set) var onTranslationXChanged: ((CGFloat) -> Void)? = nil
    private(set) var onEnd: (() -> Void)? = nil
    
    private(set) var axisMask = Axis.leadingToTrailing
    
    @State private var viewWidth: CGFloat = 0
    @State private var translationX: CGFloat = 0 {
        didSet {
            onTranslationXChanged?(translationX)
        }
    }
    @GestureState private var dragStateOffsetX: CGFloat = 0
    
    /// Init this view with:
    /// - Parameter thresholdToAction: the distance in points to trigger the action block. Defaults to 100 points.
    /// - Parameter onTranslationXChanged: the block to be invoked on the translation x of the view is changed
    /// - Parameter onAction: the block to be invoked when the swipe translation is greater than the thresholdToAction in points. Return true will restore  the translationx on action performed.
    /// - Parameter onEnd: the block to be invoked when the gesture is ended
    init(axisMask: Axis,
         thresholdToAction: CGFloat,
         onTranslationXChanged: ((CGFloat) -> Void)? = nil,
         onAction: @escaping (Axis) -> Bool,
         onEnd: (() -> Void)? = nil) {
        self.axisMask = axisMask
        self.thresholdToAction = thresholdToAction
        self.onAction = onAction
        self.onTranslationXChanged = onTranslationXChanged
        self.onEnd = onEnd
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .offset(x: translationX)
                .listenWidthChanged(onWidthChanged: { width in
                    self.viewWidth = width
                })
                .gesture(DragGesture().updating($dragStateOffsetX) { value, state, transaction in
                    // Updating method would always be invoked even is cancelled by system.
                    // We depend the state here to update the translationX state
                    state = value.translation.width
                }, including: .gesture)
                .matchParent(axis: .width, alignment: .leading)
                .onChange(of: dragStateOffsetX) { newValue in
                    // If the value is changed to zero, then trigger the end of gesture
                    if newValue == 0 {
                        triggerEnd()
                    } else {
                        if axisMask == .leadingToTrailing {
                            if newValue > 0 {
                                translationX = newValue
                            }
                        } else if axisMask == .trailingToLeading {
                            if newValue < 0 {
                                translationX = newValue
                            }
                        } else {
                            translationX = newValue
                        }
                    }
                }
        }
    }
    
    private func triggerEnd() {
        if abs(translationX) >= thresholdToAction {
            withEastOutAnimation {
                if currentAxis == .leadingToTrailing {
                    translationX = self.viewWidth
                } else {
                    translationX = -self.viewWidth
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if onAction(currentAxis) {
                    withAnimation(Animation.easeOut) {
                        translationX = 0
                    }
                }
            }
        } else {
            withEastOutAnimation {
                translationX = 0
            }
        }
        onEnd?()
    }
    
    private var currentAxis: Axis {
        if translationX > 0 {
            return .leadingToTrailing
        } else {
            return .trailingToLeading
        }
    }
}

public extension View {
    /// Apply swipe to perform action to this view.
    /// - Parameter thresholdToAction: the distance in points to trigger the action block. Defaults to 100 points.
    /// - Parameter onTranslationXChanged: the block to be invoked on the translation x of the view is changed
    /// - Parameter onAction: the block to be invoked when the swipe translation is greater than the thresholdToAction in points. Return true will restore  the translationx on action performed.
    /// - Parameter onEnd: the block to be invoked when the gesture is ended
    func swipeToAction(axisMask: SwipeToAction.Axis = .leadingToTrailing,
                       thresholdToAction: CGFloat = 100,
                       onTranslationXChanged: ((CGFloat) -> Void)? = nil,
                       onEnd: (() -> Void)? = nil,
                       onAction: @escaping (SwipeToAction.Axis) -> Bool) -> some View {
        self.modifier(SwipeToAction(axisMask: axisMask,
                                    thresholdToAction: thresholdToAction,
                                    onTranslationXChanged: onTranslationXChanged,
                                    onAction: onAction, onEnd: onEnd))
    }
}
