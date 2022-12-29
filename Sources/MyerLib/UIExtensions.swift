//
//  UIExtensions.swift
//  ProjectSort
//
//  Created by juniperphoton on 2022/2/12.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct MatchParent: ViewModifier {
    let matchWidth: Bool
    let matchHeight: Bool
    let alignment: Alignment
    
    init(matchWidth: Bool, matchHeight: Bool, alignment: Alignment) {
        self.matchWidth = matchWidth
        self.matchHeight = matchHeight
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        content.frame(maxWidth: matchWidth ? .infinity : nil,
                      maxHeight: matchHeight ? .infinity : nil, alignment: alignment)
    }
}

/// Axis to match parent in ``MatchParent``.
/// You pass this enum to ``View/matchParent(axis:alignment)`` to indicate which axis to be matched parent.
public enum MatchParentAxis {
    /// Both with and height
    case widthHeight
    /// Width only
    case width
    /// Height only
    case height
    /// None
    case none
}

public extension View {
    /// Wrap this view into a frame, which size is defined by axis parameter.
    ///
    /// - Parameter axis: the axis to match parent. See the ``MatchParent`` enum.
    /// - Parameter alignment: how the original view is aligned in the new frame, default to ``Alignment/Center``.
    @ViewBuilder
    func matchParent(axis: MatchParentAxis = .widthHeight,
                     alignment: Alignment = .center) -> some View {
        self.modifier(MatchParent(matchWidth: axis == .widthHeight || axis == .width,
                                  matchHeight: axis == .widthHeight || axis == .height,
                                  alignment: alignment))
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
    /// Add background to this view to help assit layout issue.
    func assist() -> some View {
        self.background(Color.red)
    }
}

public extension View {
    func addShadow() -> some View {
        self.shadow(color: Color.black.opacity(0.1), radius: 3, x: 3, y: 3)
    }
    
    /// Set this view to hidden if condition is meet.
    /// - Parameter condition: condition to check if this view should be hidden
    @ViewBuilder
    func hiddenIf(condition: Bool) -> some View {
        if (condition) {
            self.hidden()
        } else {
            self
        }
    }
    
    /// Run the block if condition is meet.
    /// - Parameter condition: the condition to check
    /// - Parameter block: the block to be executed if the condition is meet. This block capture the current view and should return some View.
    @ViewBuilder
    func runIf(condition: Bool, block: (Self) -> some View) -> some View {
        if (condition) {
            block(self)
        } else {
            self
        }
    }
}

public extension View {
    /// Listen the width changed of this view.
    /// - Parameter onWidthChanged: invoked on width changed
    func listenWidthChanged(onWidthChanged: @escaping (CGFloat) -> Void) -> some View {
        self.overlay(GeometryReader(content: { proxy in
            Color.clear.onChange(of: proxy.size.width) { newValue in
                onWidthChanged(newValue)
            }.onAppear {
                onWidthChanged(proxy.size.width)
            }
        }))
    }
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
    /// Compact version of ``hoverEffect``.
    /// It's available for iPad only.
    func hoverEffectCompact() -> some View {
        #if os(iOS)
        self.hoverEffect(.automatic)
        #else
        self
        #endif
    }
}
