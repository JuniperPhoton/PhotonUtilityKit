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
        withDefaultAnimation(onEnd: {
            self.fullscreenPresentation?.dismissAll()
            onEnd?()
        }, onEndDelay: 0.0) {
            self.showContent = false
        }
    }
}

public struct BottomSheetView<Content: View>: View {
    @EnvironmentObject var fullscreenPresentation: FullscreenPresentation
    
    @StateObject private var controller: BottomSheetController = BottomSheetController()
    @State private var dragOffsetY: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var startTime: Date? = nil
    @State private var safeArea: EdgeInsets = .init()

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
                        .fill(backgroundColor).ignoresSafeArea(edges: .bottom))
                    .listenHeightChanged(onHeightChanged: { height in
                        self.contentHeight = height
                    })
                    .contentShape(Rectangle())
                    .offset(y: dragOffsetY)
#if os(iOS)
                    .transition(.move(edge: .bottom))
                    .gesture(DragGesture(minimumDistance: 0).onChanged { value in
                        if value.translation.height >= 0 {
                            if startTime == nil {
                                startTime = .now
                            }
                            dragOffsetY = value.translation.height
                        }
                    }.onEnded { value in
                        if value.translation.height > 100 {
                            let startY = value.startLocation.y
                            let endY = value.predictedEndLocation.y
                            let deltaY = abs(endY - startY)
                            let deltaTime = Date.now.timeIntervalSince1970 - (startTime ?? .now).timeIntervalSince1970
                            let velocity = deltaTime == 0 ? 20 : (deltaY / deltaTime / 100)
                            let fixedVelocity = velocity.clamp(to: 10...20)
                            
                            print("velocity is \(velocity), fixed \(fixedVelocity), safa \(safeArea)")
                            startTime = nil
                            
                            withAnimation(.interpolatingSpring(stiffness: 70, damping: 272, initialVelocity: fixedVelocity)) {
                                dragOffsetY = self.contentHeight + safeArea.bottom
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                dismiss(animated: false)
                            }
                        } else {
                            withDefaultAnimation {
                                dragOffsetY = 0
                            }
                        }
                    })
#endif
                    .onTapGestureCompact {
                        // ignored
                    }
                    .measureSafeArea(safeArea: $safeArea)
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
                withDefaultAnimation {
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
        withDefaultAnimation(onEnd: {
            controller.showContent = false
            fullscreenPresentation.dismissAll()
        }) {
            self.dragOffsetY = self.contentHeight + safeArea.bottom
        }
    }
}
