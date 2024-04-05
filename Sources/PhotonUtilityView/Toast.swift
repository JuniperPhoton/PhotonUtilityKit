//
//  File.swift
//  
//
//  Created by Photon Juniper on 2022/12/25.
//

import Foundation
import SwiftUI
import PhotonUtility

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
public class AppToast: ObservableObject {
    @Published var toast: String = ""
    
    private var pendingWorkItem: DispatchWorkItem? = nil
    
    public init() {
        // empty
    }
    
    @MainActor
    public func showToast(_ notification: String, dismissTimeout: TimeInterval = 2) {
        callAsFunction(Binding.constant(notification), dismissTimeout: dismissTimeout)
    }
    
    @MainActor
    public func callAsFunction(_ notification: Binding<String>, dismissTimeout: TimeInterval = 2) {
        let toastContent = notification.wrappedValue
        if toastContent.isEmpty {
            withDefaultAnimation {
                self.toast = ""
                notification.wrappedValue = ""
            }
            return
        }
        
        withDefaultAnimation {
            self.toast = toastContent
        }
        
        pendingWorkItem?.cancel()
        pendingWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            withDefaultAnimation {
                self.toast = ""
                notification.wrappedValue = ""
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissTimeout, execute: pendingWorkItem!)
    }
    
    @MainActor
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

public enum ToastShape {
    case roundedRect(CGFloat)
    case capsule
    
    @available(iOS 16.0, *)
    var toShape: AnyShape {
        switch self {
        case .roundedRect(let radius):
            AnyShape(RoundedRectangle(cornerRadius: radius))
        case .capsule:
            AnyShape(Capsule())
        }
    }
}

fileprivate struct ToastStyle {
    var showIcon: Bool = true
    var shape: ToastShape = .capsule
}

fileprivate struct ToastColorKey: EnvironmentKey {
    static var defaultValue: ToastColor {
        ToastColor()
    }
}

fileprivate struct ToastStyleKey: EnvironmentKey {
    static var defaultValue: ToastStyle {
        ToastStyle()
    }
}

fileprivate extension EnvironmentValues {
    var toastColor: ToastColor {
        get { self[ToastColorKey.self] }
        set { self[ToastColorKey.self] = newValue }
    }
    
    var toastStyle: ToastStyle {
        get { self[ToastStyleKey.self]}
        set { self[ToastStyleKey.self] = newValue }
    }
}

public extension View {
    /// Set ``color`` as the color set to ``ToastView``.
    func toastColors(_ color: ToastColor) -> some View {
        self.environment(\.toastColor, color)
    }
    
    /// Shows/hides icon inside ``ToastView``.
    func toastShowIcon(_ showIcon: Bool) -> some View {
        self.environment(\.toastStyle, ToastStyle(showIcon: showIcon))
    }
    
    /// Set the toast style.
    func toastStyle(showIcon: Bool, shape: ToastShape) -> some View {
        self.environment(\.toastStyle, ToastStyle(showIcon: showIcon, shape: shape))
    }
}

/// Wrap this view inside a ZStack and overlay with a ``ToastView``.
///
/// - parameter appToast: the app toast state used to show or dismiss toast.
public extension View {
    func withToast(_ appToast: AppToast) -> some View {
        ZStack {
            self.zIndex(1)
            
            ToastView(appToast: appToast)
                .zIndex(2)
        }
        .environmentObject(appToast)
    }
}

/// A view to show toast managed by ``AppToast``.
/// Place this view into your fullscreen root view and that's it.
///
/// To customize the colors, use ``toastColors(_:)``, ``toastShowIcon(_:)`` method.
///
/// You use the methods in ``AppToast`` to present a toast.
/// See ``AppToast`` for more details.
public struct ToastView: View {
    @Environment(\.toastColor) private var colors: ToastColor
    
    @ObservedObject var appToast: AppToast
    
    @State private var dragYOffset: CGFloat = 0
    
    public init(appToast: AppToast) {
        self.appToast = appToast
    }
    
    public var body: some View {
        ZStack(alignment: .top) {
            if !appToast.toast.isEmpty {
                ToastContentView(toast: appToast.toast, colors: colors)
                    .offset(y: dragYOffset)
#if !os(tvOS)
                    .gesture(DragGesture().onChanged({ v in
                        if v.translation.height <= 0 {
                            dragYOffset = v.translation.height
                        }
                    }).onEnded({ v in
                        self.appToast.clear()
                        self.dragYOffset = 0
                    }))
#endif
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

fileprivate struct ToastContentView: View {
    @Environment(\.toastStyle) private var style: ToastStyle
    
    @State var showBellAnimation = false
    
    let toast: String
    let colors: ToastColor
    
    var body: some View {
        HStack {
            if style.showIcon {
                Image(systemName: "bell")
                    .renderingMode(.template)
                    .foregroundColor(colors.foregroundColor)
                    .rotationEffect(Angle(degrees: showBellAnimation ? 10 : -10))
                    .animation(.default.repeatForever(), value: showBellAnimation)
            }
            Text(LocalizedStringKey(toast))
                .foregroundColor(colors.foregroundColor)
                .multilineTextAlignment(.center)
        }.padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
            .background {
                Group {
                    if #available(iOS 16.0, *) {
                        style.shape.toShape.fill(colors.backgroundColor)
                    } else {
                        switch style.shape {
                        case .roundedRect(let radius):
                            RoundedRectangle(cornerRadius: radius).fill(colors.backgroundColor)
                        case .capsule:
                            Capsule().fill(colors.backgroundColor)
                        }
                    }
                }.addShadow()
            }
            .padding(8)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.default, value: style.showIcon)
            .onAppear {
                if style.showIcon {
                    showBellAnimation = true
                }
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
