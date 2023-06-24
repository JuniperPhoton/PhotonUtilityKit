//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/5/25.
//

import Foundation
import SwiftUI
import PhotonUtility

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
    
    public func invokeOnDismiss() {
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

public class BottomSheetController: ObservableObject {
    @Published public var showContent: Bool = false
    
    private var fullscreenPresentation: FullscreenPresentation? = nil
    
    public init() {
        // empty
    }
    
    public func setup(fullscreenPresentation: FullscreenPresentation) {
        self.fullscreenPresentation = fullscreenPresentation
    }
    
    public func dismiss(onEnd: (() -> Void)? = nil) {
        withEaseOutAnimation(duration: 0.2, onEnd: {
            self.fullscreenPresentation?.dismissAll()
            onEnd?()
        }, onEndDelay: 0.0) {
            self.showContent = false
        }
    }
}

public struct BottomSheetView<Content: View>: View {
    @EnvironmentObject var fullscreenPresentation: FullscreenPresentation
    
    @StateObject var controller: BottomSheetController = BottomSheetController()
    @State var dragOffsetY: CGFloat = 0
    @State var contentHeight: CGFloat = 0
    
    private let backgroundColor: Color
    private let content: () -> Content
    
    public init(backgroundColor: Color,
                @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        ZStack {
            if controller.showContent {
                content()
                    .environmentObject(controller)
                    .padding()
                    .frame(maxWidth: DeviceCompat.isOnPhoneOnly() ? .infinity : 600)
                    .background(UnevenRoundedRectangle(top: 12, bottom: DeviceCompat.isMac() ? 12 : 0)
                        .fill(backgroundColor).ignoresSafeArea())
                    .listenHeightChanged(onHeightChanged: { height in
                        self.contentHeight = height
                    })
                    .contentShape(Rectangle())
                    .offset(y: dragOffsetY)
#if os(iOS)
                    .transition(.move(edge: .bottom))
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        if value.translation.height >= 0 {
                            dragOffsetY = value.translation.height
                        }
                    }.onEnded { value in
                        if value.translation.height > 100 {
                            withEaseOutAnimation(duration: 0.2, onEnd: {
                                dismiss(animated: false)
                            }, onEndDelay: 0.0) {
                                dragOffsetY = self.contentHeight * 1.5
                            }
                        } else {
                            withEaseOutAnimation {
                                dragOffsetY = 0
                            }
                        }
                    })
#endif
                    .onTapGestureCompact {
                        // ignored
                    }
            }
        }.ignoresSafeArea()
#if os(macOS)
            .matchParent(axis: .widthHeight, alignment: .center)
#else
            .matchParent(axis: .widthHeight, alignment: .bottom)
#endif
            .contentShape(Rectangle())
            .background(Color.black.opacity(0.4))
            .onAppear {
                controller.setup(fullscreenPresentation: fullscreenPresentation)
                withEaseOutAnimation {
                    controller.showContent = true
                }
            }
            .onTapGestureCompact {
                dismiss(animated: true)
            }
    }
    
    private func dismiss(animated: Bool) {
        if !animated {
            fullscreenPresentation.dismissAll()
            return
        }
        withEaseOutAnimation(duration: 0.2, onEnd: {
            fullscreenPresentation.dismissAll()
        }, onEndDelay: 0.0) {
            controller.showContent = false
        }
    }
}
