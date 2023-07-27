//
//  ActionButton.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/7.
//

import Foundation
import SwiftUI
import PhotonUtility

fileprivate struct ActionButtonCustomStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.1 : 0.0)
    }
}

fileprivate struct ActionButtonStyle {
    var adaptOnUISizeClassChanged: Bool
    var stretchToWidth: Bool
    var foregroundColor: Color
    var backgroundColor: Color
    
    func adaptOnUISizeClassChanged(_ adapt: Bool) -> ActionButtonStyle {
        ActionButtonStyle(adaptOnUISizeClassChanged: adapt,
                          stretchToWidth: stretchToWidth,
                          foregroundColor: foregroundColor,
                          backgroundColor: backgroundColor)
    }
}

fileprivate struct ActionButtonStyleKey: EnvironmentKey {
    static var defaultValue: ActionButtonStyle {
        ActionButtonStyle(adaptOnUISizeClassChanged: false, stretchToWidth: false,
                          foregroundColor: .primary, backgroundColor: .accentColor)
    }
}

fileprivate extension EnvironmentValues {
    var actionButtonStyle: ActionButtonStyle {
        get {
            self[ActionButtonStyleKey.self]
        }
        set {
            self[ActionButtonStyleKey.self] = newValue
        }
    }
}

struct ActionButtonStyleModifier: ViewModifier {
    @Environment(\.actionButtonStyle) private var actionButtonStyle
    
    var adaptOnUISizeClassChanged: Bool? = nil
    var stretchToWidth: Bool? = nil
    var foregroundColor: Color? = nil
    var backgroundColor: Color? = nil
    
    func body(content: Content) -> some View {
        content.environment(\.actionButtonStyle,
                             ActionButtonStyle(adaptOnUISizeClassChanged: adaptOnUISizeClassChanged ?? actionButtonStyle.adaptOnUISizeClassChanged,
                                               stretchToWidth: stretchToWidth ?? actionButtonStyle.stretchToWidth,
                                               foregroundColor: foregroundColor ?? actionButtonStyle.foregroundColor,
                                               backgroundColor: backgroundColor ?? actionButtonStyle.backgroundColor))
    }
}

public extension View {
    /// Set whether the ``ActionButton`` to adapt on horizontal class size changes.
    func actionButtonAdaptOnUISizeClassChanged(_ adapt: Bool) -> some View {
        self.modifier(ActionButtonStyleModifier(adaptOnUISizeClassChanged: adapt))
    }
    
    /// Set whether the ``ActionButton``'s label stretch to the width.
    /// If true, this view will take the whole availabe width to layout.
    func actionButtonStretchToWidth(_ stretchToWidth: Bool) -> some View {
        self.modifier(ActionButtonStyleModifier(stretchToWidth: stretchToWidth))
    }
    
    /// Set the foreground color of ``ActionButton``.
    func actionButtonForegroundColor(_ color: Color) -> some View {
        self.modifier(ActionButtonStyleModifier(foregroundColor: color))
    }
    
    /// Set the background color of ``ActionButton``.
    func actionButtonBackgroundColor(_ color: Color) -> some View {
        self.modifier(ActionButtonStyleModifier(backgroundColor: color))
    }
}

/// A button with default style.
///
/// Use ``title`` and ``icon`` to specifiy the visual elements in this button. Note that one of these can be nil.
/// To customize the colors and other effects, use one of these methods:
///
/// - ``actionButtonForegroundColor(_:)``: Set the text and icon color.
/// - ``actionButtonBackgroundColor(_:)``: Set the background color.
/// - ``actionButtonStretchToWidth(_:)``: True if you want this button has infinity width limation.
/// - ``actionButtonAdaptOnUISizeClassChanged(_:)``: On iOS, set this to true will adapt to horizontal class size.
///
/// If this action supports loading, passing binding ``isLoading``.
///  If it's in loading state, the button would be disabled and show a progress view.
///
/// You must set the ``onClick`` to response the tap gesture.
public struct ActionButton: View {
    @Environment(\.actionButtonStyle) private var style
    
    public let title: LocalizedStringKey?
    public let icon: String?
    
    public var isLoading: Binding<Bool>
    
    public let onClick: (() -> Void)?
    
    public init(title: LocalizedStringKey? = nil,
                icon: String? = nil,
                isLoading: Binding<Bool> = .constant(false),
                onClick: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.onClick = onClick
        self.isLoading = isLoading
    }
    
    public var body: some View {
        Button {
            onClick?()
        } label: {
            labelContent
        }.buttonStyle(ActionButtonCustomStyle())
    }
    
    @available(*, deprecated, message: "Use labelContent property instead.")
    public var content: some View {
        labelContent
    }
    
    /// Get the label content inside the button.
    /// Useful if you just want the custom style of this button's label without wrapping it inside a button.
    public var labelContent: some View {
        HStack(spacing: 12) {
            if isLoading.wrappedValue {
                if #available(iOS 15.0, *) {
                    ProgressView()
                        .controlSizeCompat(.small)
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                }
            }
            
            if let icon = icon {
                Image(systemName: icon)
                    .renderingMode(.template)
                    .foregroundColor(style.foregroundColor)
            }
            
            if showTitle {
                Text(title!)
                    .font(.body.bold())
                    .foregroundColor(style.foregroundColor)
                    .lineLimit(1)
            }
        }
        .padding(DeviceCompat.isMac() ? 10 : 12)
        .frame(minHeight: 30)
        .matchParent(axis: style.stretchToWidth ? .width : .none, alignment: .center)
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(style.backgroundColor))
        .disabled(isLoading.wrappedValue)
        .opacity(isLoading.wrappedValue ? 0.5 : 1.0)
    }
    
#if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    
    private var showTitle: Bool {
        guard title != nil else { return false }
        
        if !style.adaptOnUISizeClassChanged {
            return true
        }
        
        return sizeClass == .regular
    }
#else
    private var showTitle: Bool {
        return title != nil
    }
#endif
}
