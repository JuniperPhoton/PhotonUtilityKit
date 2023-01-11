//
//  File.swift
//  
//
//  Created by Photon Juniper on 2022/12/25.
//

import Foundation
import SwiftUI
import MyerLib

/// A controller that manage toast, coorporated with ``ToastView``.
///
/// # Overview
/// You call the object like a function to perform toast showing like:
/// ```swift
/// var showToast: AppToast
///
/// showToast("Your localized toast string")
/// ```
///
/// It's recommended for you to pass the ``AppToast`` object as environment object so you can access it from your views.
///
/// ```swift
/// view.environmentObject(appToast)
/// ```
///
/// Alternately, you can use the ``View/toast(text:)`` modifier to bind a text as toast:
///
/// ```swift
/// view.toast($toastContent)
/// ```
@MainActor
public class AppToast: ObservableObject {
    @Published var toast: String = ""
    
    private var pendingWorkItem: DispatchWorkItem? = nil
    
    public init() {
        // empty
    }
    
    public func showToast(_ notification: String) {
        callAsFunction(Binding.constant(notification))
    }
    
    public func callAsFunction(_ notification: Binding<String>) {
        withEastOutAnimation {
            self.toast = notification.wrappedValue
            print("dwccc show toast \(self.toast)")
        }
        
        pendingWorkItem?.cancel()
        pendingWorkItem = DispatchWorkItem(block: {
            withEastOutAnimation {
                self.toast = ""
                print("dwccc clear toast \(self.toast)")
                notification.wrappedValue = ""
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: pendingWorkItem!)
    }
    
    public func clear() {
        pendingWorkItem?.perform()
    }
}

public struct ToastColor {
    let foregroundColor: Color
    let backgroundColor: Color
    
    public init(foregroundColor: Color = .black, backgroundColor: Color = .white) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

/// A view to show toast managed by ``AppToast``.
/// Place this view into your fullscreen root view and that's it.
///
/// You use the methods in ``AppToast`` to present a toast.
/// See ``AppToast`` for more details.
public struct ToastView: View {
    @ObservedObject var appToast: AppToast
    let colors: ToastColor
    
    private let dragGesture = DragGesture()
    
    @State var dragYOffset: CGFloat = 0
    
    public init(appToast: AppToast, colors: ToastColor = .init()) {
        self.appToast = appToast
        self.colors = colors
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            if !appToast.toast.isEmpty {
                ToastContentView(toast: appToast.toast, colors: colors)
                    .offset(y: dragYOffset)
                    .gesture(dragGesture.onChanged({ v in
                        dragYOffset = v.translation.height
                    }).onEnded({ v in
                        self.appToast.clear()
                        self.dragYOffset = 0
                    }))
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

fileprivate struct ToastContentView: View {
    @State var showBellAnimation = false
    
    let toast: String
    let colors: ToastColor
    
    var body: some View {
        HStack {
            Image(systemName: "bell")
                .renderingMode(.template)
                .foregroundColor(colors.foregroundColor)
                .rotationEffect(Angle(degrees: showBellAnimation ? 10 : -10))
                .animation(.default.repeatForever(), value: showBellAnimation)
            Text(LocalizedStringKey(toast))
                .foregroundColor(colors.foregroundColor)
        }.padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background(Capsule().fill(colors.backgroundColor).addShadow())
            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                showBellAnimation = true
            }
    }
}

public extension View {
    /// Show toast of text.
    /// To use this modifier, the attached view should have environment object of ``AppToast``.
    /// - Parameter text: a binding to a toast string. Set this to a non empty value to present a toast.
    func toast(text: Binding<String>) -> some View {
        self.modifier(ToastModifier(toast: text))
    }
}

fileprivate struct ToastModifier: ViewModifier {
    @EnvironmentObject var appToast: AppToast
    
    let toast: Binding<String>
    
    func body(content: Content) -> some View {
        content.onChange(of: toast.wrappedValue) { newValue in
            appToast(toast)
        }
    }
}
