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
    
    @Published fileprivate var safeArea: EdgeInsets = .init()
    @Published fileprivate var contentHeight: CGFloat = 0
    @Published fileprivate var dragOffsetY: CGFloat = 0
    @Published fileprivate var startTime: Date? = nil
    
    private var fullscreenPresentation: FullscreenPresentation? = nil
    
    public init() {
        // empty
    }
    
    public func setup(fullscreenPresentation: FullscreenPresentation) {
        self.fullscreenPresentation = fullscreenPresentation
    }
    
    public func dismiss(onEnd: (() -> Void)? = nil) {
        withDefaultAnimation(onEnd: {
            self.showContent = false
            self.fullscreenPresentation?.dismissAll()
            onEnd?()
        }) {
#if os(iOS)
            self.dragOffsetY = self.contentHeight + self.safeArea.bottom
#else
            self.showContent = false
#endif
        }
    }
}

public struct BottomSheetView<Content: View>: View {
    @EnvironmentObject var fullscreenPresentation: FullscreenPresentation
    
    @StateObject private var controller: BottomSheetController = BottomSheetController()
    
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
                contentView
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
    
    @ViewBuilder
    private var contentView: some View {
        content()
            .environmentObject(controller)
            .padding()
            .frame(maxWidth: DeviceCompat.isOnPhoneOnly() ? .infinity : 600)
            .background(UnevenRoundedRectangle(top: 12, bottom: DeviceCompat.isMac() ? 12 : 0)
                .fill(backgroundColor).ignoresSafeArea(edges: .bottom))
            .listenHeightChanged(onHeightChanged: { height in
                controller.contentHeight = height
            })
            .contentShape(Rectangle())
            .offset(y: controller.dragOffsetY)
#if os(iOS)
            .transition(.move(edge: .bottom))
            .highPriorityGesture(DragGesture().onChanged { value in
                if value.translation.height >= 0 {
                    if controller.startTime == nil {
                        controller.startTime = .now
                    }
                    controller.dragOffsetY = value.translation.height
                }
            }.onEnded { value in
                if value.translation.height > 100 {
                    let startY = value.startLocation.y
                    let endY = value.predictedEndLocation.y
                    let deltaY = abs(endY - startY)
                    let deltaTime = Date.now.timeIntervalSince1970 - (controller.startTime ?? .now).timeIntervalSince1970
                    let velocity = deltaTime == 0 ? 20 : (deltaY / deltaTime / 100)
                    let fixedVelocity = velocity.clamp(to: 10...20)
                    
                    print("velocity is \(velocity), fixed \(fixedVelocity), safa \(controller.safeArea)")
                    controller.startTime = nil
                    
                    withAnimation(.interpolatingSpring(stiffness: 70, damping: 272, initialVelocity: fixedVelocity)) {
                        controller.dragOffsetY = controller.contentHeight + controller.safeArea.bottom
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss(animated: false)
                    }
                } else {
                    withDefaultAnimation {
                        controller.dragOffsetY = 0
                    }
                }
            })
#endif
            .onTapGestureCompact {
                // ignored
            }
            .measureSafeArea(safeArea: $controller.safeArea)
    }
    
    private func dismiss(animated: Bool) {
        if !animated {
            fullscreenPresentation.dismissAll()
            return
        }
        
        controller.dismiss()
    }
}
