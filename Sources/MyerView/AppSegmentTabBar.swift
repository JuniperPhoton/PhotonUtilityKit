//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/2/13.
//

import SwiftUI
import MyerLib

public struct TextAppSegmentTabBar<T: Hashable>: View {
    let selection: Binding<T>
    let sources: [T]
    let scrollable: Bool
    var foregroundColor: Color
    var selectedForegroundColor: Color
    var backgroundColor: Color
    var horizontalInset: CGFloat = 12
    let textKeyPath: KeyPath<T, String>
    
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
            Text(LocalizedStringKey(item[keyPath: textKeyPath]))
                .bold()
                .foregroundColor(selection.wrappedValue == item ? selectedForegroundColor : foregroundColor.opacity(0.7))
                .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                .lineLimit(1)
        }
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
    let label: (T) -> V
        
    public var body: some View {
        if scrollable {
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    content
                }.onChange(of: selection.wrappedValue) { newValue in
                    withEaseOutAnimation {
                        reader.scrollTo(newValue)
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
                Capsule().fill(foregroundColor)
                    .frame(width: frameState.selectedCapsuleFrame.width,
                           height: frameState.selectedCapsuleFrame.height)
                    .offset(x: frameState.relativeX,
                            y: frameState.relativeY)
            }
        }.listenFrameChanged { rect in
            frameState.updateContentFrame(rect: rect)
        }
    }
}
