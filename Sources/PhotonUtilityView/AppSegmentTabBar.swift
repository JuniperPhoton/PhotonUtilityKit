//
//  SwiftUIView.swift
//
//
//  Created by Photon Juniper on 2023/2/13.
//

import SwiftUI
import PhotonUtility
import SwiftUIIntrospect

#if !os(tvOS)
/// A ``AppSegmentTabBar`` which use ``Text`` as content view and Capsule as shape.
extension TextAppSegmentTabBar where S == Capsule {
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
        self.init(
            selection: selection,
            sources: sources,
            scrollable: scrollable,
            foregroundColor: foregroundColor,
            selectedForegroundColor: selectedForegroundColor,
            backgroundColor: backgroundColor,
            horizontalInset: horizontalInset,
            textKeyPath: textKeyPath,
            shape: Capsule(), 
            helpTooltips: helpTooltips,
            keyboardShortcut: keyboardShortcut
        )
    }
}

/// A ``AppSegmentTabBar`` which use ``Text`` as content view.
public struct TextAppSegmentTabBar<T: Hashable, S: Shape>: View {
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
    
    var shape: S
    
    /// The horizontal inset of this view. Default to 12pt.
    var horizontalInset: CGFloat = 12
    
    /// Key path to find the text of a specified item.
    let textKeyPath: KeyPath<T, String>
    
    /// The bundle in which the ``Sources`` are located.
    /// This could affect how the text resources are searched.
    let sourcesBundle: Bundle
    
    /// A block to get the text showing on help tooltips from a specified item.
    var helpTooltips: ((T) -> String)?
    
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
                sourcesBundle: Bundle = Bundle.main,
                shape: S,
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
        self.sourcesBundle = sourcesBundle
        self.helpTooltips = helpTooltips
        self.shape = shape
        self.keyboardShortcut = keyboardShortcut
    }
    
    public var body: some View {
        AppSegmentTabBar(selection: selection,
                         sources: sources,
                         scrollable: scrollable,
                         foregroundColor: foregroundColor,
                         backgroundColor: backgroundColor,
                         horizontalInset: horizontalInset,
                         shape: shape,
                         keyboardShortcut: keyboardShortcut) { item in
            bodyText(item: item)
        }
    }
    
    private func bodyText(item: T) -> some View {
        Text(LocalizedStringKey(item[keyPath: textKeyPath]), bundle: sourcesBundle)
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
    
    private(set) var contentFrame: CGRect = .zero
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
            self.selectedCapsuleFrame = itemFrame ?? .zero
        }
    }
}

private let nameSpaceName = "AppSegmentTabBar"

public struct AppSegmentTabBar<T: Hashable, V: View, S: Shape>: View {
    @StateObject private var frameState = FrameState<T>()
    
    let selection: Binding<T>
    let sources: [T]
    let scrollable: Bool
    var foregroundColor: Color
    var backgroundColor: Color
    var shape: S
    var horizontalInset: CGFloat = 12
    var keyboardShortcut: ((T) -> KeyEquivalent)?
    let label: (T) -> V
    
    @State private var autoScrollState: AutoScrollState<T>
    
    public init(selection: Binding<T>,
                sources: [T],
                scrollable: Bool,
                foregroundColor: Color,
                backgroundColor: Color,
                horizontalInset: CGFloat,
                shape: S,
                keyboardShortcut: ((T) -> KeyEquivalent)? = nil,
                label: @escaping (T) -> V) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.horizontalInset = horizontalInset
        self.keyboardShortcut = keyboardShortcut
        self.shape = shape
        self.label = label
        self._autoScrollState = State(initialValue: AutoScrollState(value: nil, in: sources))
    }
    
    public var body: some View {
        ZStack {
            if scrollable {
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
            } else {
                content
            }
        }.coordinateSpace(name: "AppSegmentTabBar")
    }
    
    @ViewBuilder
    private var content: some View {
        HStack(spacing: 2) {
            ForEach(sources, id: \.hashValue) { item in
                label(item).contentShape(Rectangle())
                    .asPlainButton {
                        DeviceCompat.triggerVibrationFeedback()
                        selection.wrappedValue = item
                    }
                    .runIf(condition: keyboardShortcut != nil) { v in
                        v.keyboardShortcut(keyboardShortcut!(item))
                    }
                    .listenFrameChanged(coordinateSpace: .named(nameSpaceName)) { rect in
                        frameState.updateItemFrame(item: item, frame: rect)
                        
                        if selection.wrappedValue == item {
                            frameState.updateSelectedFrame(item: item)
                        }
                    }
                    .onChange(of: selection.wrappedValue) { newValue in
                        withTransaction(selection.transaction) {
                            frameState.updateSelectedFrame(item: newValue)
                        }
                    }
                    .id(item)
            }
        }.padding(.horizontal, horizontalInset)
            .padding(backgroundColor == .clear ? 0 : 3)
            .background(ZStack(alignment: .topLeading) {
                shape.fill(backgroundColor)
                
                if !frameState.selectedCapsuleFrame.isEmpty {
                    shape.fill(foregroundColor)
                        .frame(width: frameState.selectedCapsuleFrame.width,
                               height: frameState.selectedCapsuleFrame.height)
                        .offset(x: frameState.relativeX,
                                y: frameState.relativeY)
                }
            }, alignment: .topLeading)
            .listenFrameChanged(coordinateSpace: .named(nameSpaceName)) { rect in
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
    private var lastValue: T? = nil
    
    /// The value to trigger changed, normally the id of the view
    @Published var value: T? = nil {
        willSet {
            lastValue = value
        }
    }
    
    /// The visible rect to scroll to.
    @Published var rect: CGRect
    
    private let values: [T]
    
    var anotherNextItemToScrollTo: T? {
        if let lastValue = lastValue, let value = value {
            findAnotherNextItemToScrollTo(current: lastValue, next: value, in: values)
        } else {
            nil
        }
    }
    
    init(value: T?, in values: [T]) {
        self.value = value
        self.values = values
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
                    proxy.scrollTo(state.anotherNextItemToScrollTo)
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
            .introspect(.scrollView, on: .macOS(.v11, .v12, .v13, .v14, .v15)) { nsScrollView in
                DispatchQueue.main.async {
                    self.nsScrollView = nsScrollView
                }
            }
        }
    }
}
#endif

private func findAnotherNextItemToScrollTo<T: Equatable>(current: T, next: T, in all: [T]) -> T? {
    guard let currentIndex = all.firstIndex(of: current),
          let nextIndex = all.firstIndex(of: next) else {
        return nil
    }
    
    if nextIndex > currentIndex {
        let nextNextIndex = nextIndex + 1
        return all[safeIndex: nextNextIndex]
    } else if nextIndex < currentIndex {
        let nextNextIndex = nextIndex - 1
        return all[safeIndex: nextNextIndex]
    }
    
    return nil
}
#endif
