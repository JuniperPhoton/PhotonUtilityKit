//
//  SwiftUIView.swift
//
//
//  Created by Photon Juniper on 2023/2/13.
//

import SwiftUI
import PhotonUtility
import SwiftUIIntrospect

/// A ``AppSegmentTabBar`` which use ``Text`` as content view.
public struct TextAppSegmentTabBar<T: Hashable>: View {
    /// Binding to the selected item. When an item is selected, the binding value will be changed.
    let selection: Binding<T>
    
    /// All available items of ``T``.
    let sources: [T]
    
    /// If the list is scrollable horizontally. If you know the texts are short then you can set this to false.
    let scrollable: Bool
    
    /// The foreground color of the selected background.
    var foregroundColor: Color
    
    /// The foreground color of the text when it's not selected.
    var selectedForegroundColor: Color
    
    /// The background color of the whole view.
    var backgroundColor: Color
    
    /// The horizontal inset of this view. Default to 12pt.
    var horizontalInset: CGFloat = 12
    
    /// Key path to find the text of a specified item.
    let textKeyPath: KeyPath<T, String>
    
    /// A block to get the text showing on help tooltips from a specified item.
    var helpTooltips: ((T) -> String)?
#if !os(tvOS)
    
    /// A block to get the keyboard shortcut.
    var keyboardShortcut: ((T) -> KeyEquivalent)?
    
    public init(selection: Binding<T>,
                sources: [T],
                scrollable: Bool,
                foregroundColor: Color,
                selectedForegroundColor: Color = .white,
                backgroundColor: Color,
                horizontalInset: CGFloat = 0,
                textKeyPath: KeyPath<T, String>,
                helpTooltips: ((T) -> String)? = nil,
                keyboardShortcut: ((T) -> KeyEquivalent)? = nil) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.selectedForegroundColor = selectedForegroundColor
        self.backgroundColor = backgroundColor
        self.horizontalInset = horizontalInset
        self.textKeyPath = textKeyPath
        self.helpTooltips = helpTooltips
        self.keyboardShortcut = keyboardShortcut
    }
    
    public var body: some View {
        AppSegmentTabBar(selection: selection,
                         sources: sources,
                         scrollable: scrollable,
                         foregroundColor: foregroundColor,
                         backgroundColor: backgroundColor,
                         horizontalInset: horizontalInset,
                         keyboardShortcut: keyboardShortcut) { item in
            bodyText(item: item)
        }
    }
#else
    public init(selection: Binding<T>,
                sources: [T],
                scrollable: Bool,
                foregroundColor: Color,
                selectedForegroundColor: Color = .white,
                backgroundColor: Color,
                horizontalInset: CGFloat = 0,
                textKeyPath: KeyPath<T, String>) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.selectedForegroundColor = selectedForegroundColor
        self.backgroundColor = backgroundColor
        self.horizontalInset = horizontalInset
        self.textKeyPath = textKeyPath
    }
    
    public var body: some View {
        AppSegmentTabBar(selection: selection,
                         sources: sources,
                         scrollable: scrollable,
                         foregroundColor: foregroundColor,
                         backgroundColor: backgroundColor,
                         horizontalInset: horizontalInset) { item in
            bodyText(item: item)
        }
    }
#endif
    
    private func bodyText(item: T) -> some View {
        Text(LocalizedStringKey(item[keyPath: textKeyPath]))
            .bold()
            .foregroundColor(selection.wrappedValue == item ? selectedForegroundColor : foregroundColor.opacity(0.7))
            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
            .lineLimit(1)
            .runIf(condition: helpTooltips != nil, block: { v in
                v.help(LocalizedStringKey(helpTooltips!(item)))
            })
    }
}

class FrameState<T: Hashable>: ObservableObject {
    @Published var selectedCapsuleFrame: CGRect = .zero
    
    var relativeX: CGFloat {
        return selectedCapsuleFrame.minX - contentFrame.minX
    }
    
    var relativeY: CGFloat {
        return selectedCapsuleFrame.minY - contentFrame.minY
    }
    
    private var contentFrame: CGRect = .zero
    private var itemFrames: [T: CGRect] = [:]
    
    func updateContentFrame(rect: CGRect) {
        self.contentFrame = rect
    }
    
    func updateItemFrame(item: T, frame: CGRect) {
        self.itemFrames[item] = frame
    }
    
    func updateSelectedFrame(item: T) {
        let itemFrame = itemFrames[item]
        if selectedCapsuleFrame != itemFrame {
            // When the view first appears, the minY of the frame will be negative,
            // setting this frame will cause weird animation, so we skip it.
            if itemFrame?.minY ?? 0 < 0 {
                return
            }
            self.selectedCapsuleFrame = itemFrame ?? .zero
        }
    }
}

public struct AppSegmentTabBar<T: Hashable, V: View>: View {
    @StateObject private var frameState = FrameState<T>()
    
    let selection: Binding<T>
    let sources: [T]
    let scrollable: Bool
    var foregroundColor: Color
    var backgroundColor: Color
    var horizontalInset: CGFloat = 12
#if !os(tvOS)
    var keyboardShortcut: ((T) -> KeyEquivalent)?
#endif
    let label: (T) -> V
    
    @State private var autoScrollState = AutoScrollState<T>(value: nil)
    
#if !os(tvOS)
    public init(selection: Binding<T>,
                sources: [T],
                scrollable: Bool,
                foregroundColor: Color,
                backgroundColor: Color,
                horizontalInset: CGFloat,
                keyboardShortcut: ((T) -> KeyEquivalent)? = nil,
                label: @escaping (T) -> V) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.horizontalInset = horizontalInset
        self.keyboardShortcut = keyboardShortcut
        self.label = label
    }
#else
    public init(selection: Binding<T>,
                sources: [T],
                scrollable: Bool,
                foregroundColor: Color,
                backgroundColor: Color,
                horizontalInset: CGFloat,
                label: @escaping (T) -> V) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.horizontalInset = horizontalInset
        self.label = label
    }
#endif
    
    public var body: some View {
        if scrollable {
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    content
                }
                .autoScrollOnChanged(state: autoScrollState)
                .onChange(of: selection.wrappedValue) { newValue in
                    DispatchQueue.main.async {
                        self.autoScrollState.rect = frameState.selectedCapsuleFrame
                        self.autoScrollState.value = newValue
                    }
                }
            }
        } else {
            content
        }
    }
    
    @ViewBuilder
    private var content: some View {
        HStack(spacing: 2) {
            ForEach(sources, id: \.hashValue) { item in
                label(item).contentShape(Rectangle())
                    .asPlainButton {
                        DeviceCompat.triggerVibrationFeedback()
                        
                        withDefaultAnimation {
                            selection.wrappedValue = item
                        }
                    }
#if !os(tvOS)
                    .runIf(condition: keyboardShortcut != nil) { v in
                        v.keyboardShortcut(keyboardShortcut!(item))
                    }
#endif
                    .id(item)
                    .listenFrameChanged { rect in
                        frameState.updateItemFrame(item: item, frame: rect)
                        
                        if selection.wrappedValue == item {
                            frameState.updateSelectedFrame(item: item)
                        }
                    }
                    .onChange(of: selection.wrappedValue) { newValue in
                        withDefaultAnimation {
                            frameState.updateSelectedFrame(item: newValue)
                        }
                    }
            }
        }.padding(.horizontal, horizontalInset)
            .padding(backgroundColor == .clear ? 0 : 3)
            .background(ZStack(alignment: .topLeading) {
                Capsule().fill(backgroundColor)
                
                if !frameState.selectedCapsuleFrame.isEmpty {
                    Capsule().fill(foregroundColor)
                        .frame(width: frameState.selectedCapsuleFrame.width,
                               height: frameState.selectedCapsuleFrame.height)
                        .offset(x: frameState.relativeX,
                                y: frameState.relativeY)
                }
            }, alignment: .topLeading).listenFrameChanged { rect in
                frameState.updateContentFrame(rect: rect)
            }
    }
}

extension ScrollView {
    func autoScrollOnChanged<T>(state: AutoScrollState<T>) -> some View where T: Equatable & Hashable {
        self.modifier(ScrollViewViewAutoScrollViewModifier(state: state))
    }
}

class AutoScrollState<T>: ObservableObject where T: Equatable & Hashable {
    /// The value to trigger changed, normally the id of the view
    @Published var value: T? = nil
    
    /// The visible rect to scroll to.
    @Published var rect: CGRect
    
    init(value: T?) {
        self.value = value
        self.rect = .zero
    }
}

#if canImport(UIKit)
struct ScrollViewViewAutoScrollViewModifier<T>: ViewModifier where T: Equatable & Hashable {
    @ObservedObject var state: AutoScrollState<T>
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content.onChange(of: state.value) { newValue in
                withDefaultAnimation {
                    proxy.scrollTo(state.value)
                }
            }
        }
    }
}
#elseif canImport(AppKit)
struct ScrollViewViewAutoScrollViewModifier<T>: ViewModifier where T: Equatable & Hashable {
    @ObservedObject var state: AutoScrollState<T>
    @State var nsScrollView: NSScrollView? = nil
    
    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content.onChange(of: state.value) { newValue in
                self.nsScrollView?.scroll(toRect: state.rect)
            }
            .introspect(.scrollView, on: .macOS(.v11, .v12, .v13, .v14)) { nsScrollView in
                DispatchQueue.main.async {
                    self.nsScrollView = nsScrollView
                }
            }
        }
    }
}
#endif
