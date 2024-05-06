//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/9.
//

import SwiftUI

/// A scroll view that has sticky header and footer.
///
/// You should NOT use .safeAreaInset(), which will block all the tap gesture in the safe area(even it's transparent).
///
/// This view itself adds a Spacer as a stub view to the `ScrollView` sharing the same height of the provided header/footer view.
///
@available(*, deprecated, message: "Use safeAreaInset(edge:alignment:spacing:content:) API instead.")
public struct StickyHeaderFooterScrollView<Content: View, Header: View, Footer: View>: View {
    let showsIndicators: Bool
    
    @ViewBuilder
    var contentView: () -> Content
    
    @ViewBuilder
    var headerView: () -> Header
    
    @ViewBuilder
    var footerView: () -> Footer
    
    @State private var topHeaderHeight: CGFloat = 0
    @State private var bottomFooterHeight: CGFloat = 0
    
    public init(showsIndicators: Bool = false,
                @ViewBuilder contentView: @escaping () -> Content,
                @ViewBuilder headerView: @escaping () -> Header = { EmptyView() },
                @ViewBuilder footerView: @escaping () -> Footer = { EmptyView() }
    ) {
        self.headerView = headerView
        self.footerView = footerView
        self.contentView = contentView
        self.showsIndicators = showsIndicators
    }
    
    public var body: some View {
        ZStack {
            headerView()
                .zIndex(1)
                .listenHeightChanged { self.topHeaderHeight = $0 }
                .matchHeight(.top)
            
            ScrollView(showsIndicators: showsIndicators) {
                Spacer().frame(height: topHeaderHeight)
                contentView()
                Spacer().frame(height: bottomFooterHeight)
            }.zIndex(0)
            
            footerView()
                .zIndex(1)
                .listenHeightChanged { self.bottomFooterHeight = $0 }
                .matchHeight(.bottom)
        }
    }
}
