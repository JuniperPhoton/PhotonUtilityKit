//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/1.
//

import SwiftUI

/// A unified version of ``UIPageView`` and ``NSPageView``.
///
/// Internally it uses the ``UIPageViewController`` and ``NSPageController`` to provide scrolling feature by pages.
public struct BridgedPageView<T: Equatable, V: View>: View {
    let selection: Binding<Int>
    let pageObjects: [T]
    let idKeyPath: KeyPath<T, String>
    let transitionStyle: TransitionStyle
    let onContentPrepared: ((T) -> Void)?
    let contentView: (T) -> V
    
    /// Construct a ``BridgedPageView``.
    ///
    /// - parameter selection: The Binding to the selected index. It's the single source of truth in SwiftUI,
    ///                        however the internal view from UIKit or AppKit have their own state of selected index.
    ///                        Any changes to the selection will reflect the internal state, and the other way around.
    /// - parameter pageObjects: The objects to be displayed in pages.
    /// - parameter idKeyPath: The ``KeyPath`` to get the string type id of a page object.
    /// - parameter transitionStyle: The transition style for the page view. This will be available only on iOS and iPadOS.
    /// - parameter onContentPrepared: When the view controller associated a page object is loaded, you can do some prefetch work.
    /// - parameter contentView: The block to return the view to display for each page object.
    public init(selection: Binding<Int>,
                pageObjects: [T],
                idKeyPath: KeyPath<T, String>,
                transitionStyle: TransitionStyle = .scroll,
                onContentPrepared: ((T) -> Void)? = nil,
                @ViewBuilder contentView: @escaping (T) -> V) {
        self.selection = selection
        self.pageObjects = pageObjects
        self.idKeyPath = idKeyPath
        self.transitionStyle = transitionStyle
        self.onContentPrepared = onContentPrepared
        self.contentView = contentView
    }
    
    public var body: some View {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        NSPageView(
            selection: selection,
            pageObjects: pageObjects,
            idKeyPath: idKeyPath,
            onContentPrepared: onContentPrepared,
            contentView: contentView
        )
#elseif canImport(UIKit)
        UIPageView(
            selection: selection,
            pageObjects: pageObjects,
            idKeyPath: idKeyPath,
            transitionStyle: transitionStyle,
            onContentPrepared: onContentPrepared,
            contentView: contentView
        )
#else
        EmptyView()
#endif
    }
}
