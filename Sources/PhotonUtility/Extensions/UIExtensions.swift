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
    
    /// Make this view's width infinity.
    func matchWidth(_ alignment: Alignment = .center) -> some View {
        self.matchParent(axis: .width, alignment: alignment)
    }
    
    /// Make this view's height infinity.
    func matchHeight(_ alignment: Alignment = .center) -> some View {
        self.matchParent(axis: .height, alignment: alignment)
    }
}

public extension Color {
    /// Init a ``Color`` with a hex string.
    /// - parameter hexString: a hex string starts with `#` and has this format: #AARRGGBB or #RRGGBB
    init?(hexString: String?) {
        guard let hexString = hexString else {
            return nil
        }
        
        if !hexString.hasPrefix("#") {
            return nil
        }
        
        let start = hexString.index(hexString.startIndex, offsetBy: 1)
        let hexColor = String(hexString[start...])
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let a: CGFloat
            if hexColor.count == 8 {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            } else {
                a = 1.0
            }
            let r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x000000ff) / 255
            
            self = Color.init(red: r, green: g, blue: b, opacity: a)
        } else {
            return nil
        }
    }
    
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
    func addShadow(color: Color = Color.black.opacity(0.1),
                   x: CGFloat = 3.0, y: CGFloat = 3.0) -> some View {
        self.shadow(color: color, radius: 3, x: x, y: y)
    }
    
    /// Set this view to hidden if condition is meet.
    /// - Parameter condition: condition to check if this view should be hidden
    @ViewBuilder
    func hiddenIf(condition: Bool) -> some View {
        if condition {
            self.hidden()
        } else {
            self
        }
    }
    
    /// Run the block if condition is meet.
    /// 
    /// Be aware that this may destroy the identity of the view. Don't use this if you can switch state using ViewModifier.
    ///
    /// - Parameter condition: the condition to check
    /// - Parameter block: the block to be executed if the condition is meet. This block capture the current view and should return some View.
    @ViewBuilder
    func runIf(condition: Bool, block: (Self) -> some View) -> some View {
        if condition {
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
    
    /// Listen the height changed of this view.
    /// - Parameter onHeightChanged: invoked on height changed
    func listenHeightChanged(onHeightChanged: @escaping (CGFloat) -> Void) -> some View {
        self.overlay(GeometryReader(content: { proxy in
            Color.clear.onChange(of: proxy.size.height) { newValue in
                onHeightChanged(newValue)
            }.onAppear {
                onHeightChanged(proxy.size.height)
            }
        }))
    }
    
    /// Listen the size changed of this view.
    /// - Parameter onSizeChanged: invoked on size changed
    func listenSizeChanged(onSizeChanged: @escaping (CGSize) -> Void) -> some View {
        self.overlay(GeometryReader(content: { proxy in
            Color.clear.onChange(of: proxy.size) { newValue in
                onSizeChanged(newValue)
            }.onAppear {
                onSizeChanged(proxy.size)
            }
        }))
    }
    
    /// Listen the frame changed of this view.
    /// - Parameter onFrameChanged: invoked on frame changed
    func listenFrameChanged(coordinateSpace: CoordinateSpace = .global,
                            onFrameChanged: @escaping (CGRect) -> Void) -> some View {
        self.overlay(GeometryReader(content: { proxy in
            Color.clear.onChange(of: proxy.frame(in: coordinateSpace)) { newValue in
                onFrameChanged(newValue)
            }.onAppear {
                onFrameChanged(proxy.frame(in: coordinateSpace))
            }
        }))
    }
}

public extension View {
    /// Get the safe area insets of this view.
    /// If this view's offset can be changed, this view modifier should be placed at the
    /// bottom of a view.
    ///
    /// MyView().offset(x: x, y: y)
    ///     .measureSafeArea($safeArea)
    ///
    func measureSafeArea(safeArea: Binding<EdgeInsets>) -> some View {
        ViewSafeAreaWrapper(safeArea: safeArea, content: self)
    }
}

private struct ViewSafeAreaWrapper<V: View>: View {
    @Binding var safeArea: EdgeInsets
    let content: V
    
    var body: some View {
        content.background {
            GeometryReader { proxy in
                Color.clear.ignoresSafeArea(edges: .bottom).onAppear {
                    safeArea = proxy.safeAreaInsets
                    print("safe area onAppear \(safeArea)")
                }.onChange(of: proxy.safeAreaInsets) { newValue in
                    safeArea = newValue
                    print("safe area onChange \(safeArea)")
                }
            }
        }
    }
}

/// Convenient extensions to create ``EdgeInsets``.
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

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension ProposedViewSize: CustomStringConvertible {
    public var description: String {
        return "\(String(describing: self.width)) x \(String(describing: self.height))"
    }
}

/// Represents a selected ``parent`` URL with its content ``files``.
/// To access the ``files``, you must access them within``tryAccess(block:)``.
///
/// Note that the ``startAccessingSecurityScopedResource`` method should be invoked by the root folder the user selected, not the contents of dir.
public struct ScopedURLContent: CustomStringConvertible {
    public let parent: URL?
    public let files: [URL]
    
    public var description: String {
        return "parent \(String(describing: parent)), files count \(files.count)"
    }
    
    public var isEmpty: Bool {
        return files.isEmpty
    }
    
    public var count: Int {
        return files.count
    }
    
    public init(parent: URL?, files: [URL]) {
        self.parent = parent
        self.files = files
    }
    
    public func tryAccess<T>(block: () -> T) -> T {
        let access = parent?.startAccessingSecurityScopedResource() ?? false
        
        defer {
            if access {
                parent?.stopAccessingSecurityScopedResource()
            }
        }
        
        return block()
    }
}

public extension View {
    @available(iOS 15.0, macOS 12.0, *)
    func importFolderOrFiles(isPresented: Binding<Bool>, types: [UTType],
                             allowsMultipleSelection: Bool, onSucess: @escaping ([URL])->Void) -> some View {
#if !os(tvOS)
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

@frozen
public enum HoverEffectCompact {
    case automatic
    case highlight
    case lift
    
    #if os(iOS)
    var wrappedEffect: HoverEffect {
        switch self {
        case .automatic:
            return HoverEffect.automatic
        case .highlight:
            return HoverEffect.highlight
        case .lift:
            return HoverEffect.lift
        }
    }
    #endif
}

public extension View {
    /// Compact version of ``hoverEffect``.
    /// It's available for iPad only.
    func hoverEffectCompact(_ effect: HoverEffectCompact = .automatic) -> some View {
#if os(iOS)
        self.hoverEffect(effect.wrappedEffect)
#else
        self
#endif
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension View {
    /// Wrap this view inside a plain button.
    func asPlainButton(role: ButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(role: role, action: action) {
            self
        }.buttonStyle(CustomPlainButtonSytle())
    }
    
    /// Wrap this view inside a button with automatic button style.
    /// You can apply the button style later.
    func asButton(role: ButtonRole? = nil, action: @escaping () -> Void) -> some View {
        Button(role: role, action: action) {
            self
        }
    }
}

public extension View {
    /// Wrap this view inside a plain button.
    func asPlainButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }.buttonStyle(CustomPlainButtonSytle())
    }
    
    /// Wrap this view inside a button with automatic button style.
    /// You can apply the button style later.
    func asButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self
        }
    }
}

fileprivate struct CustomPlainButtonSytle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.1 : 0.0)
    }
}

public struct BorderedProminentButtonStyleCompact: ButtonStyle {
#if !os(tvOS)
    @Environment(\.controlSize) var controlSize
#endif
    
    public init() {
        // empty
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        return configuration.label.foregroundColor(.white)
            .padding(EdgeInsets(top: useLargeControl() ? 8 : 2,
                                leading: 8,
                                bottom: useLargeControl() ? 8 : 2,
                                trailing: 8))
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.accentColor)
                .shadow(color: .black.opacity(0.01), radius: 2, x: 1, y: 1))
            .brightness(configuration.isPressed ? -0.1 : 0.0)
    }
    
    private func useLargeControl() -> Bool {
#if !os(tvOS)
        return controlSize == .large
#else
        return false
#endif
    }
}

#if !os(tvOS)
public extension View {
    /// Make this view focusable by assigning a ``KeyEquivalent`` to this and perform ``performFocus`` to focus when
    /// the keyboard shortcut is pressed.
    func focusableByKeyboard(_ keyEquivalent: KeyEquivalent = "f",
                             _ performFocus: @escaping () -> Void) -> some View {
        self.background(
            Button("") {
                performFocus()
            }.keyboardShortcut(keyEquivalent).opacity(0.0)
        )
    }
    
    /// Make this view focusable by assigning a ``KeyEquivalent`` to this.
    /// As the keyboard shortcut is pressed, the ``focusState`` will be set to true.
    ///
    /// To access the underline ``FocusState<Bool>`` from
    ///
    /// ```swift
    /// @FocusState var focus
    /// ```
    ///
    /// You can use the underline one: _focous.
    ///
    @available(iOS 15.0, macOS 12.0, *)
    func focusableByKeyboard(_ keyEquivalent: KeyEquivalent = "f",
                             focusState: FocusState<Bool>.Binding) -> some View {
        self.background(
            Button("") {
                focusState.wrappedValue = true
            }.keyboardShortcut(keyEquivalent).opacity(0.0)
        )
    }
}
#endif
