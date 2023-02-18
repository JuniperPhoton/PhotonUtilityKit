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
    let textKeyPath: KeyPath<T, String>
    
    public init(selection: Binding<T>, sources: [T], scrollable: Bool,
                foregroundColor: Color, selectedForegroundColor: Color = .white,
                backgroundColor: Color, textKeyPath: KeyPath<T, String>) {
        self.selection = selection
        self.sources = sources
        self.scrollable = scrollable
        self.foregroundColor = foregroundColor
        self.selectedForegroundColor = selectedForegroundColor
        self.backgroundColor = backgroundColor
        self.textKeyPath = textKeyPath
    }
    
    public var body: some View {
        AppSegmentTabBar(selection: selection,
                         sources: sources,
                         scrollable: scrollable,
                         foregroundColor: foregroundColor,
                         backgroundColor: backgroundColor) { item in
            Text(LocalizedStringKey(item[keyPath: textKeyPath]))
                .bold()
                .foregroundColor(selection.wrappedValue == item ? selectedForegroundColor : foregroundColor.opacity(0.7))
                .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                .lineLimit(1)
        }
    }
}

public struct AppSegmentTabBar<T: Hashable, V: View>: View {
    let selection: Binding<T>
    let sources: [T]
    let scrollable: Bool
    var foregroundColor: Color
    var backgroundColor: Color
    let label: (T) -> V
    
    @Namespace var namespace
    
    public var body: some View {
        if scrollable {
            ScrollViewReader { reader in
                ScrollView(.horizontal, showsIndicators: false) {
                    content
                }.onChange(of: selection.wrappedValue) { newValue in
                    withEastOutAnimation {
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
            ForEach(sources, id: \.hashValue) { item in
                ZStack {
                    label(item).contentShape(Rectangle())
                }.background {
                    if selection.wrappedValue == item {
                        Capsule().fill(foregroundColor)
                            .matchedGeometryEffect(id: "capsule", in: namespace)
                    }
                }
                #if !os(tvOS)
                .onTapGesture {
                    DeviceCompat.triggerVibrationFeedback()
                    
                    withEastOutAnimation {
                        selection.wrappedValue = item
                    }
                }
                #endif
                .id(item)
            }
        }.padding(3).background(Capsule().fill(backgroundColor))
    }
}
