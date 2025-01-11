//
//  File.swift
//
//
//  Created by Photon Juniper on 2022/12/29.
//

import Foundation
import SwiftUI

public extension View {
    /// Apply swipe to perform action to this view.
    /// - Parameter thresholdToAction: the distance in points to trigger the action block. Defaults to 100 points.
    /// - Parameter onTranslationXChanged: the block to be invoked on the translation x of the view is changed
    /// - Parameter onAction: the block to be invoked when the swipe translation is greater than the thresholdToAction in points. Return true will restore  the translation x on action performed.
    /// - Parameter onEnd: the block to be invoked when the gesture is ended
    @ViewBuilder
    func swipeToAction(
        enabled: Bool = true,
        axisMask: SwipeToAction.Axis = .leadingToTrailing,
        thresholdToAction: CGFloat = 100,
        translationX: Binding<CGFloat>,
        onEnd: (() -> Void)? = nil,
        onAction: @escaping (SwipeToAction.Axis) -> Bool
    ) -> some View {
        self.modifier(
            SwipeToAction(
                enabled: enabled,
                axisMask: axisMask,
                thresholdToAction: thresholdToAction,
                translationX: translationX,
                onAction: onAction,
                onEnd: onEnd
            )
        )
    }
}

/// A modifier to support swipe to perform an action of a view.
public struct SwipeToAction: ViewModifier {
    public enum Axis {
        case leadingToTrailing
        case trailingToLeading
        case both
    }
    
    private(set) var thresholdToAction: CGFloat
    private(set) var onAction: (Axis) -> Bool
    private(set) var onEnd: (() -> Void)? = nil
    
    private(set) var axisMask = Axis.leadingToTrailing
    private(set) var enabled = true
    
    @State private var viewWidth: CGFloat = 0
    @Binding var translationX: CGFloat
    
    @GestureState private var dragStateOffsetX: CGFloat = 0
    
    /// Init this view with:
    /// - parameter enabled: Whether the swipe to action is enabled.
    /// - parameter thresholdToAction: the distance in points to trigger the action block. Defaults to 100 points.
    /// - parameter onTranslationXChanged: the block to be invoked on the translation x of the view is changed
    /// - parameter onAction: the block to be invoked when the swipe translation is greater than the thresholdToAction in points. Return true will restore  the translation x on action performed.
    /// - parameter onEnd: the block to be invoked when the gesture is ended
    init(enabled: Bool = true,
         axisMask: Axis,
         thresholdToAction: CGFloat,
         translationX: Binding<CGFloat>,
         onAction: @escaping (Axis) -> Bool,
         onEnd: (() -> Void)? = nil) {
        self.enabled = enabled
        self.axisMask = axisMask
        self.thresholdToAction = thresholdToAction
        self.onAction = onAction
        self._translationX = translationX
        self.onEnd = onEnd
    }
    
    private var dragGesture: some Gesture {
        DragGesture().updating($dragStateOffsetX) { value, state, transaction in
            // Updating method would always be invoked even is cancelled by system.
            // We rely on the state here to update the translationX state.
            state = value.translation.width
        }
    }
    
    public func body(content: Content) -> some View {
#if !os(tvOS)
        content
            .offset(x: translationX)
            .listenWidthChanged { width in
                if self.viewWidth != width {
                    self.viewWidth = width
                }
            }
            // On iOS 18, using the default minimumDistance will cause the gesture to
            // "eat" all gesture installed on the super view, which may be the ScrollView.
            // https://stackoverflow.com/questions/79225290/ios-18-drag-gesture-blocks-scrollview
            .gesture(TapGesture().exclusively(before: dragGesture), including: enabled ? .gesture : .none)
            .matchParent(axis: .width, alignment: .leading)
            .onChange(of: dragStateOffsetX) { newValue in
                onDragStateOffsetXChanged(newValue)
            }
#else
        content
#endif
    }
    
    private func onDragStateOffsetXChanged(_ newValue: CGFloat) {
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
    
    private func triggerEnd() {
        if abs(translationX) >= thresholdToAction {
            withDefaultAnimation {
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
            withDefaultAnimation {
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
