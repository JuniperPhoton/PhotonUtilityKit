//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/6/20.
//

import SwiftUI
import PhotonUtility

/// A model for providing tab information for ``TabViewCompact``.
public struct TabViewCompactModel<ID: Hashable & Equatable>: Identifiable, Equatable {
    public let id: ID
    public let label: String
    public let systemImage: String
    
    public init(id: ID, label: String, systemImage: String) {
        self.id = id
        self.label = label
        self.systemImage = systemImage
    }
}

/// A TabView built with SwiftUI.
/// It load all view content at once in the begining and hide the content view if it's not visible by setting its ZIndex.
///
/// By doing so, all view content states are preserved while switching tabs in contrast to the official TabView which will
/// recreate all selected view content.
public struct TabViewCompact<ID: Hashable, Data: RandomAccessCollection<TabViewCompactModel<ID>>, Content: View>: View {
    var selection: Binding<TabViewCompactModel<ID>>
    let backgroundColor: Color
    var forEach: ForEach<Data, ID, Content>
    
    @StateObject private var keybordFrameObserver = KeybordFrameObserver()
    
    public init(selection: Binding<TabViewCompactModel<ID>>,
                backgroundColor: Color,
                forEach: () -> ForEach<Data, ID, Content>) {
        self.selection = selection
        self.backgroundColor = backgroundColor
        self.forEach = forEach()
    }
    
    public var body: some View {
        ZStack {
            ZStack {
                ForEach(forEach.data, id: \.id) { tab in
                    forEach.content(tab)
                        .matchHeight()
                        .background(backgroundColor)
                        .zIndex(tab == selection.wrappedValue ? 100 : 0)
                }
            }.matchHeight(.top).safeAreaInset(edge: .bottom) {
                if keybordFrameObserver.keyboardFrame.isEmpty {
                    HStack {
                        ForEach(forEach.data, id: \.id) { tab in
                            VStack {
                                Image(systemName: tab.systemImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                Text(tab.label).font(.footnote)
                            }
                            .foregroundColor(selection.wrappedValue == tab ? .accentColor : .primary)
                            .animation(nil, value: selection.wrappedValue)
                            .matchWidth()
                            .asPlainButton {
                                selection.wrappedValue = tab
                            }
                        }
                    }
                    .padding(8)
                    .background {
                        Rectangle().fill(backgroundColor).ignoresSafeArea()
                            .overlay {
                                Divider().matchHeight(.top)
                            }
                    }
                    .transition(.opacity)
                }
            }
        }
        .matchHeight()
        .animation(.easeInOut, value: keybordFrameObserver.keyboardFrame)
    }
}
