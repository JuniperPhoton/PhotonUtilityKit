//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/1.
//

import SwiftUI

public struct BridgedPageView<T: Equatable, V: View>: View {
    let selection: Binding<Int>
    let pageObjects: [T]
    let idKeyPath: KeyPath<T, String>
    let contentView: (T) -> V
    
    public init(selection: Binding<Int>,
                pageObjects: [T],
                idKeyPath: KeyPath<T, String>,
                contentView: @escaping (T) -> V) {
        self.selection = selection
        self.pageObjects = pageObjects
        self.idKeyPath = idKeyPath
        self.contentView = contentView
    }
    
    public var body: some View {
        #if os(macOS)
        NSPageView(selection: selection, pageObjects: pageObjects, idKeyPath: idKeyPath, contentView: contentView)
        #elseif os(iOS)
        UIPageView(selection: selection, pageObjects: pageObjects, idKeyPath: idKeyPath, contentView: contentView)
        #else
        EmptyView()
        #endif
    }
}
