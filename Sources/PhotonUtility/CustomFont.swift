//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/2/14.
//

import SwiftUI

let fontName = "DIN Condensed"

/// Check if is NOT in Chinese local environment.
public func isNotChineseLocalEnvironment() -> Bool {
    let localized = NSLocalizedString("TestLocal", tableName: nil, bundle: Bundle.module, value: "", comment: "")
    return localized == "EnglishLocal"
}

/// A ViewModifier to apply to a ``Text`` to use a custom font.
/// More specifically, for English, it uses ``DIN Condensed`` font, for Chinese, it uses the system font.
public struct CustomFont: ViewModifier {
    let fixedEnglishFont: Bool
    let size: CGFloat
    let relativeTo: Font.TextStyle
    
    /// Init a ``CustomFont``.
    ///
    /// - parameter fixedEnglishFont: always use English font. If you ensure the text will always be English, set this true.
    /// - parameter size: font size related to ``relativeTo``
    /// - parameter relativeTo: related ``Font.TextStyle``
    public init(fixedEnglishFont: Bool, size: CGFloat, relativeTo: Font.TextStyle) {
        self.fixedEnglishFont = fixedEnglishFont
        self.size = size
        self.relativeTo = relativeTo
    }
        
    @ViewBuilder
    public func body(content: Content) -> some View {
        let useEnglish = isNotChineseLocalEnvironment() || fixedEnglishFont
        if useEnglish {
            content.font(.custom(fontName, size: size, relativeTo: relativeTo))
                .fixCondensedOffset()
        } else {
            content.font(.system(size: size - 10).bold())
        }
    }
}

public extension View {
    /// For a condensed font, move the baseline down by 2pt to make it look better.
    @ViewBuilder
    func fixCondensedOffset() -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
            self.baselineOffset(-2)
        } else {
            self
        }
    }
}

public extension Text {
    /// Apply ``CustomFont`` to a ``Text``.
    func applyCustomFont(fixedEnglishFont: Bool, size: CGFloat) -> some View {
        self.bold().modifier(CustomFont(fixedEnglishFont: fixedEnglishFont, size: size, relativeTo: .title))
    }
    
    /// Apply ``CustomFont`` to a ``Text`` with predefined text size optimized for TV.
    func applyCustomTitleFont(fixedEnglishFont: Bool) -> some View {
        self.bold().modifier(CustomFont(fixedEnglishFont: fixedEnglishFont,
                                        size: DeviceCompat.isTV() ? 100 : 60, relativeTo: .title))
    }
    
    /// Apply ``CustomFont`` to a ``Text`` with predefined text size optimized for TV.
    func applyCustomSubTitleFont(fixedEnglishFont: Bool) -> some View {
        self.bold().modifier(CustomFont(fixedEnglishFont: fixedEnglishFont,
                                        size: DeviceCompat.isTV() ? 80 : 40, relativeTo: .title))
    }
}

public struct FocusStyleForTV: ViewModifier {
    @Environment(\.isFocused) var isFocused
    
    var onFocusChanged: ((Bool) -> Void)? = nil
    
    public func body(content: Content) -> some View {
        Group {
            if isFocused {
                content.colorMultiply(Color.black)
            } else {
                content
            }
        }.onChange(of: isFocused) { newValue in
            onFocusChanged?(newValue)
        }
    }
}
