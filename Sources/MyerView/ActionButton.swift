//
//  ActionButton.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/7.
//

import Foundation
import SwiftUI
import MyerLib

/// A button with default style.
///
/// Use ``title`` and ``icon`` to specifiy the element in this button. Note that either of them can be nil.
/// Use ``style`` to specify the color scheme of this button.
/// Use ``frameConfigration`` to specifiy how the button will layout in parent and specifiy some geo effects.
///
/// If this action supports loading, passing binding ``isLoading``. If it's in loading state, the button would be disabled and show a progress view.
///
/// You must set the ``onClick`` to response the tap gesture.
public struct ActionButton: View {
    public let title: LocalizedStringKey?
    public let icon: String?
    
    public let style: ActionButtonStyle
    public let frameConfigration: FrameConfiguration
            
    @State var isHovered = false
    @State var isTapped = false
    
    public var isLoading: Binding<Bool>
    
    public let onClick: (() -> Void)?
    
    public init(title: LocalizedStringKey? = nil,
                icon: String? = nil,
                isLoading: Binding<Bool> = .constant(false),
                style: ActionButtonStyle,
                frameConfigration: FrameConfiguration = FrameConfiguration(),
                onClick: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.style = style
        self.frameConfigration = frameConfigration
        self.onClick = onClick
        self.isLoading = isLoading
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            if isLoading.wrappedValue {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
            }
            
            if (icon != nil) {
                Image(systemName: icon!)
                    .renderingMode(.template)
                    .foregroundColor(style.foregroundColor)
            }
            
            if (shouldShowTitle()) {
                Text(title!)
                    .font(.body.bold())
                    .foregroundColor(style.foregroundColor)
                    .lineLimit(1)
                    .applyEffect(effect: frameConfigration.geoEffect)
            }
        }.padding(12)
            .frame(minHeight: 30)
            .matchParent(axis: frameConfigration.stretchToWidth ? .width : .none, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(style.backgroundColor).opacity(getOpacityOnViewState()))
            .runIf(condition: onClick != nil, block: { v in
                v.onTapGesture {
                    isHovered = false
                    onClick?()
                }
            })
        #if !os(watchOS)
            .onHover { hover in
                withAnimation {
                    isHovered = hover
                }
            }
        #endif
            .disabled(isLoading.wrappedValue)
            .opacity(isLoading.wrappedValue ? 0.5 : 1.0)
    }
    
    private func getOpacityOnViewState() -> Double {
        if (isHovered) {
            return 0.7
        }
        
        if (isTapped) {
            return 0.6
        }
        
        return 1.0
    }
    
#if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
#endif
    
    private func shouldShowTitle() -> Bool {
        if (title == nil) {
            return false
        }
        
#if os(iOS)
        if (!frameConfigration.adaptOnUISizeClassChanged) {
            return title != nil
        }
        return sizeClass == .regular && title != nil
        
#else
        return title != nil
#endif
    }
}

/// Effects applied to ``FrameConfiguration``.
///
/// Typically you use ``MatchedGeometryEffect(id:namespace:)`` to animate view's frame or position between layouts.
public enum Effect {
    case none
    case MatchedGeometryEffect(id: String, namespace: Namespace.ID, property: MatchedGeometryProperties)
}

/// Controls how the button will layout in parent and specifiy some geo effects.
///
/// If ``stretchToWidth`` is true, then the button will take as wide as much it can be. Otherwise it bahaves like "wrapContent" effect.
/// You use ``adaptOnUISizeClassChanged`` to let the button hide icon if  there is no enough space to display it. Note that this takes effect for iOS and iPadOS only.
public struct FrameConfiguration {
    public let stretchToWidth: Bool
    public let adaptOnUISizeClassChanged: Bool
    public let geoEffect: Effect
    
    public init(stretchToWidth: Bool = false,
                adaptOnUISizeClassChanged: Bool = false,
                geoEffect: Effect = .none) {
        self.stretchToWidth = stretchToWidth
        self.adaptOnUISizeClassChanged = adaptOnUISizeClassChanged
        self.geoEffect = geoEffect
    }
}

/// Specify the ``foregroundColor`` and ``backgroundColor`` of this button.
public struct ActionButtonStyle {
    public let foregroundColor: Color
    public let backgroundColor: Color
    
    public init(foregroundColor: Color, backgroundColor: Color) {
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
}

fileprivate extension View {
    @ViewBuilder
    func applyEffect(effect: Effect) -> some View {
        switch effect {
        case .MatchedGeometryEffect(let id, let namespace, let properties):
            self.matchedGeometryEffect(id: id, in: namespace, properties: properties)
        default:
            self
        }
    }
}
