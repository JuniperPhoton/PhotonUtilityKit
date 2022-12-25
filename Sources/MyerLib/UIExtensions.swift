//
//  UIExtensions.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

public struct PressActions: ViewModifier {
    public var onPress: () -> Void
    public var onRelease: () -> Void
    
    public init(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) {
        self.onPress = onPress
        self.onRelease = onRelease
    }
    
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

public struct MatchParent: ViewModifier {
    public let matchWidth: Bool
    public let matchHeight: Bool
    public let alignment: Alignment
    
    public init(matchWidth: Bool, matchHeight: Bool, alignment: Alignment) {
        self.matchWidth = matchWidth
        self.matchHeight = matchHeight
        self.alignment = alignment
    }
    
    public func body(content: Content) -> some View {
        content.frame(maxWidth: matchWidth ? .infinity : nil,
                      maxHeight: matchHeight ? .infinity : nil, alignment: alignment)
    }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

public extension View {
    func assist() -> some View {
        self.background(Color.blue)
    }
}

public extension View {
    func addShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 3, x: 3, y: 3)
    }
    
    @ViewBuilder
    func hiddenIf(condition: Bool) -> some View {
        if (condition) {
            self.hidden()
        } else {
            self
        }
    }
    
    @ViewBuilder
    func runIf(condition: Bool, block: (Self) -> some View) -> some View {
        if (condition) {
            block(self)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func matchParent(matchWidth: Bool = true,
                     matchHeight: Bool = true,
                     alignment: Alignment = .center) -> some View {
        self.modifier(MatchParent(matchWidth: matchWidth, matchHeight: matchHeight, alignment: alignment))
    }
    
    @ViewBuilder
    func matchParent(axis: MatchParentAxis = .widthHeight,
                     alignment: Alignment = .center) -> some View {
        self.modifier(MatchParent(matchWidth: axis == .widthHeight || axis == .width,
                                  matchHeight: axis == .widthHeight || axis == .height,
                                  alignment: alignment))
    }
}

public enum MatchParentAxis {
    case widthHeight
    case width
    case height
}

public extension EdgeInsets {
    static func createUnified(inset: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
    }
    
    static func createVertical(inset: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0)
    }
    
    static func createHorizontal(inset: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset)
    }
    
    static func create(_ top: CGFloat, _ leading: CGFloat, _ bottom: CGFloat, _ trailing: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

extension CGSize: CustomStringConvertible {
    public var description: String {
        return "\(self.width) x \(self.height)"
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
extension ProposedViewSize: CustomStringConvertible {
    public var description: String {
        return "\(String(describing: self.width)) x \(String(describing: self.height))"
    }
}

public extension View {
    @available(iOS 15.0, macOS 12.0, *)
    func importFolderOrFiles(isPresented: Binding<Bool>, types: [UTType],
                             allowsMultipleSelection: Bool, onSucess: @escaping ([URL])->Void) -> some View {
        #if !os(watchOS)
        return self.fileImporter(isPresented: isPresented, allowedContentTypes: types,
                                 allowsMultipleSelection: allowsMultipleSelection) { result in
            defer {
                isPresented.wrappedValue = false
            }
            switch result {
            case .success(let urls):
                onSucess(urls)
                break
            case .failure(_):
                break
            }
        }
        #else
        return self
        #endif
    }
}

public extension View {
    func hoverEffectCompact() -> some View {
        #if os(iOS)
        self.hoverEffect(.automatic)
        #else
        self
        #endif
    }
}
