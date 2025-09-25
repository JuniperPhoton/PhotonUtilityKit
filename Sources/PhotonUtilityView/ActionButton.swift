//
//  ActionButton.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/7.
//

import Foundation
import SwiftUI
import PhotonUtility
import PhotonLegacyCompat

fileprivate struct ActionButtonCustomStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.1 : 0.0)
    }
}

public struct ActionButtonStyle {
    var adaptOnUISizeClassChanged: Bool
    var stretchToWidth: Bool
    var foregroundColor: Color
    var backgroundColor: Color
    var useContinuousStyle: Bool
    var radius: CGFloat
    
    init(
        adaptOnUISizeClassChanged: Bool,
        stretchToWidth: Bool,
        foregroundColor: Color,
        backgroundColor: Color,
        useContinuousStyle: Bool,
        radius: CGFloat
    ) {
        self.adaptOnUISizeClassChanged = adaptOnUISizeClassChanged
        self.stretchToWidth = stretchToWidth
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.useContinuousStyle = useContinuousStyle
        self.radius = radius
    }
    
    func adaptOnUISizeClassChanged(_ adapt: Bool) -> ActionButtonStyle {
        ActionButtonStyle(
            adaptOnUISizeClassChanged: adapt,
            stretchToWidth: stretchToWidth,
            foregroundColor: foregroundColor,
            backgroundColor: backgroundColor,
            useContinuousStyle: useContinuousStyle,
            radius: radius
        )
    }
}

public extension EnvironmentValues {
    @Entry var actionButtonStyle: ActionButtonStyle = ActionButtonStyle(
        adaptOnUISizeClassChanged: false,
        stretchToWidth: false,
        foregroundColor: .primary,
        backgroundColor: .accentColor,
        useContinuousStyle: true,
        radius: actionButtonDefaultRadius
    )
    
    @Entry var actionButtonUsesLiquidGlass: Bool = false
}

struct ActionButtonStyleModifier: ViewModifier {
    @Environment(\.actionButtonStyle) private var actionButtonStyle
    
    var adaptOnUISizeClassChanged: Bool? = nil
    var stretchToWidth: Bool? = nil
    var foregroundColor: Color? = nil
    var backgroundColor: Color? = nil
    var useContinuousStyle: Bool? = nil
    var radius: CGFloat? = nil
    
    func body(content: Content) -> some View {
        content.environment(
            \.actionButtonStyle,
             ActionButtonStyle(
                adaptOnUISizeClassChanged: adaptOnUISizeClassChanged ?? actionButtonStyle.adaptOnUISizeClassChanged,
                stretchToWidth: stretchToWidth ?? actionButtonStyle.stretchToWidth,
                foregroundColor: foregroundColor ?? actionButtonStyle.foregroundColor,
                backgroundColor: backgroundColor ?? actionButtonStyle.backgroundColor,
                useContinuousStyle: useContinuousStyle ?? actionButtonStyle.useContinuousStyle,
                radius: radius ?? actionButtonStyle.radius
             )
        )
    }
}

public extension View {
    /// Set whether the ``ActionButton`` to adapt on horizontal class size changes.
    func actionButtonAdaptOnUISizeClassChanged(_ adapt: Bool) -> some View {
        self.modifier(ActionButtonStyleModifier(adaptOnUISizeClassChanged: adapt))
    }
    
    /// Set whether the ``ActionButton``'s label stretch to the width.
    /// If true, this view will take the whole available width to layout.
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
    
    /// Set the style of round rectangle style of ``ActionButton``.
    func actionButtonUseContinuousStyle(_ use: Bool) -> some View {
        self.modifier(ActionButtonStyleModifier(useContinuousStyle: use))
    }
}

public extension ActionButtonLabel where Shape == RoundedRectangle {
    init(
        title: LocalizedStringKey? = nil,
        icon: String? = nil,
        radius: CGFloat = actionButtonDefaultRadius,
        isLoading: Binding<Bool> = .constant(false)
    ) {
        self.init(
            title: title,
            icon: icon,
            shape: RoundedRectangle(cornerRadius: radius),
            isLoading: isLoading
        )
    }
}

/// The label component of ``ActionButton``.
/// Useful if you just want the style but not the button function.
public struct ActionButtonLabel<Shape: SwiftUI.Shape>: View {
    @Environment(\.actionButtonStyle) private var style
    @Environment(\.actionButtonUsesLiquidGlass) private var useLiquidGlass
    
    public let title: LocalizedStringKey?
    public let icon: String?
    public let shape: Shape
    public var isLoading: Binding<Bool>
    
    public init(
        title: LocalizedStringKey? = nil,
        icon: String? = nil,
        shape: Shape,
        isLoading: Binding<Bool> = .constant(false)
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.shape = shape
    }
    
    public var body: some View {
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
        .geometryGroupCompat()
        .padding(DeviceCompat.isMac() ? 10 : 12)
        .frame(minHeight: 30)
        .matchParent(axis: style.stretchToWidth ? .width : .none, alignment: .center)
        .contentShape(Rectangle())
        .liquidGlassIfAvailable { v in
            if #available(iOS 26, macOS 26, tvOS 26, *), useLiquidGlass {
                v.glassEffect(
                    .regular.interactive().tint(style.backgroundColor),
                    in: shape
                )
            } else {
                v.background {
                    shape.fill(style.backgroundColor)
                }
            }
        } fallback: { v in
            v.background {
                shape.fill(style.backgroundColor)
            }
        }
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

extension ActionButton where Shape == RoundedRectangle {
    public init(
        title: LocalizedStringKey? = nil,
        icon: String? = nil,
        radius: CGFloat = 8,
        isLoading: Binding<Bool> = .constant(false),
        onClick: (() -> Void)? = nil
    ) {
        self.init(
            title: title,
            icon: icon,
            in: RoundedRectangle(cornerRadius: radius),
            isLoading: isLoading,
            onClick: onClick
        )
    }
}

public let actionButtonDefaultRadius: CGFloat = 8

/// A button with default style.
///
/// Use ``title`` and ``icon`` to specify the visual elements in this button. Note that one of these can be nil.
/// To customize the colors and other effects, use one of these methods:
///
/// - ``actionButtonForegroundColor(_:)``: Set the text and icon color.
/// - ``actionButtonBackgroundColor(_:)``: Set the background color.
/// - ``actionButtonStretchToWidth(_:)``: True if you want this button has infinity width limitation.
/// - ``actionButtonAdaptOnUISizeClassChanged(_:)``: On iOS, set this to true will adapt to horizontal class size.
/// - ``actionButtonUseContinuousStyle(_:)``: Set the rounded style.
///
/// If this action supports loading, passing binding ``isLoading``.
///  If it's in loading state, the button would be disabled and show a progress view.
///
/// You must set the ``onClick`` to response the tap gesture.
public struct ActionButton<Shape: SwiftUI.Shape>: View {
    @Environment(\.actionButtonStyle) private var style
    @Environment(\.actionButtonUsesLiquidGlass) private var actionButtonUsesLiquidGlass
    
    public let title: LocalizedStringKey?
    public let icon: String?
    public let shape: Shape
    
    public var isLoading: Binding<Bool>
    
    public let onClick: (() -> Void)?
    
    public init(
        title: LocalizedStringKey? = nil,
        icon: String? = nil,
        in shape: Shape,
        isLoading: Binding<Bool> = .constant(false),
        onClick: (() -> Void)? = nil
    ) {
        self.title = title
        self.icon = icon
        self.onClick = onClick
        self.isLoading = isLoading
        self.shape = shape
    }
    
    public var body: some View {
        Button {
            onClick?()
        } label: {
            ActionButtonLabel(
                title: title,
                icon: icon,
                shape: shape,
                isLoading: isLoading
            )
        }.liquidGlassIfAvailable { v in
            if actionButtonUsesLiquidGlass, #available(iOS 26, macOS 26, tvOS 26, *) {
                v.buttonStyle(.plain)
            } else {
                v.buttonStyle(ActionButtonCustomStyle())
            }
        } fallback: { v in
            v.buttonStyle(ActionButtonCustomStyle())
        }
    }
}
