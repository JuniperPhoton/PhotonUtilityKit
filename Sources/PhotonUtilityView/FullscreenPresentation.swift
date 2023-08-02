//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/8/2.
//

import SwiftUI
import PhotonUtility

public extension View {
    /// Wrap this view inside a container that supports presenting fullscreen content.
    /// Pass the ``fullscreenPresentation`` to control how the fullscreen content is displayed.
    func withFullscreenPresentation(_ fullscreenPresentation: FullscreenPresentation) -> some View {
        FullscreenRootView(fullscreenPresentation: fullscreenPresentation, contentBelow: self)
    }
}

private struct FullscreenRootView<V: View>: View {
    @ObservedObject var fullscreenPresentation: FullscreenPresentation
    
    var contentBelow: V
    
    var body: some View {
        ZStack {
            contentBelow.zIndex(0)
            
            if let view = fullscreenPresentation.presentedView {
                ZStack {
                    AnyView(view)
                }.matchParent()
                    .zIndex(1)
                    .transition(fullscreenPresentation.transition)
                    .onDisappear {
                        fullscreenPresentation.invokeOnDismiss()
                    }
            }
        }.ignoresSafeArea().environmentObject(fullscreenPresentation).transaction { current in
            if let override = fullscreenPresentation.transcation {
                current = override
            }
        }
    }
}

/// Control the display of fullscreen content along with ``withFullscreenPresentation`` method.
/// You use ``present(animated:transition:view:onDismiss:)`` to present a view to be displayed in fullscreen.
/// You use ``dismissAll(animated:transition:)`` to dismiss all views.
///
/// Note that only one view can be displayed at the same time.
public class FullscreenPresentation: ObservableObject {
    @Published public var presentedView: (any View)? = nil
    
    @Published public var transcation: Transaction? = nil
    @Published public var transition: AnyTransition = .identity
    
    private var onDismiss: (() -> Void)? = nil
    
    public init() {
        // empty
    }
    
    public func present(animated: Bool = true, transition: AnyTransition = .opacity, view: any View,
                        onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
        
        withTransaction(createTranscation(animated: animated)) {
            self.presentedView = view
            self.transition = transition
        }
    }
    
    public func dismissAll(animated: Bool = true, transition: AnyTransition = .opacity) {
        withTransaction(createTranscation(animated: animated)) {
            self.presentedView = nil
            self.transition = transition
        }
    }
    
    func invokeOnDismiss() {
        self.onDismiss?()
        self.onDismiss = nil
    }
    
    private func createTranscation(animated: Bool) -> Transaction {
        if animated {
            return Transaction(animation: .easeOut)
        } else {
            return Transaction()
        }
    }
}
