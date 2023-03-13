//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/2/13.
//

import SwiftUI
import PhotonUtility
import Introspect

public struct TextAppSegmentTabBar<T: Hashable>: View {
    let selection: Binding<T>
    let sources: [T]
    let scrollable: Bool
    var foregroundColor: Color
    var selectedForegroundColor: Color
    var backgroundColor: Color
    var horizontalInset: CGFloat = 12
    let textKeyPath: KeyPath<T, String>
    
#if !os(tvOS)
    var keyboardShortcut: ((T) -> KeyEquivalent)?
    
    public init(selection: Binding<T>,
                sources: [T],
                scrollable: Bool,
                foregroundColor: Color,
                selectedForegroundColor: Color = .white,
                backgroundColor: Color,
                horizontalInset: CGFloat = 0,
                textKeyPath: KeyPath<T, String>,
                keyboardShortcut: ((T) -> KeyEquivalent)? = nil) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.selectedForegroundColor = selectedForegroundColor
        self.backgroundColor = backgroundColor
        self.horizontalInset = horizontalInset
        self.textKeyPath = textKeyPath
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
        self.selectedCapsuleFrame = itemFrame ?? .zero
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
    
    @State var autoScrollState = AutoScrollState<T>(value: nil)

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
    
    private var content: some View {
        HStack(spacing: 2) {
            Spacer().frame(width: horizontalInset)
            ForEach(sources, id: \.hashValue) { item in
                label(item).contentShape(Rectangle())
                    .asPlainButton {
                        DeviceCompat.triggerVibrationFeedback()
                        
                        withEaseOutAnimation {
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
                        withEaseOutAnimation {
                            frameState.updateSelectedFrame(item: newValue)
                        }
                    }
            }
            Spacer().frame(width: horizontalInset)
        }.padding(3).background {
            ZStack(alignment: .topLeading) {
                Capsule().fill(backgroundColor)
                
                if !frameState.selectedCapsuleFrame.isEmpty {
                    Capsule().fill(foregroundColor)
                        .frame(width: frameState.selectedCapsuleFrame.width,
                               height: frameState.selectedCapsuleFrame.height)
                        .offset(x: frameState.relativeX,
                                y: frameState.relativeY)
                }
            }
        }.listenFrameChanged { rect in
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
                withEaseOutAnimation {
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
            .introspectScrollView { nsScrollView in
                self.nsScrollView = nsScrollView
            }
        }
    }
}
#endif
