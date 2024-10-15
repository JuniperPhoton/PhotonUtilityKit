//
//  StaggeredHStack.swift
//  MyerTidy (iOS)
//
//  Created by Photon Juniper on 2022/11/29.
//

import Foundation
import SwiftUI

/// A view to layout children in a staggered way like this:
///
/// With enough space:
///  [View1] [View2] [View3]
///  [View4]
///
/// With not enough space:
///  [View1] [View2]
///  [View3] [View4]
///
/// When the width changes, it would apply animation automatically.
///
/// Currently not support spacing feature, and you would like to apply padding to your views.
@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
public struct StaggeredGrid<Content: View>: View {
    let animated: Bool
    @State var width: CGFloat? = nil
        
    var content: () -> Content
    
    public init(animated: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.animated = animated
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { proxy in
                Color.clear.onChange(of: proxy.size.width) { newValue in
                    if animated {
                        withAnimation {
                            self.width = newValue
                        }
                    } else {
                        self.width = newValue
                    }
                }
            }.frame(maxHeight: 0)
            
            StaggeredGridLayout {
                content()
            }.frame(maxWidth: width == nil ? nil: width! - 5, maxHeight: nil, alignment: .leading)
        }
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate struct StaggeredGridLayout: Layout {
    static var layoutProperties: LayoutProperties {
        var properties = LayoutProperties()
        properties.stackOrientation = .horizontal
        return properties
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let maxItemHeight = subviews.map { v in
            v.sizeThatFits(.unspecified).height
        }.max() ?? 0
        
        let widthInOneLine: CGFloat = subviews.reduce(0) { partialResult, v in
            partialResult + v.sizeThatFits(.unspecified).width
        }
        
        let maxItemWidth: CGFloat = subviews.map { v in
            v.sizeThatFits(.unspecified).width
        }.max() ?? 0
        
        var size: CGSize = .zero
        
        if proposal.width == nil || proposal.width == .infinity {
            // For ideal width, all items are layout in one line
            size.width = widthInOneLine
            size.height = maxItemHeight
        } else if proposal.width == 0 {
            // For min size, the layout behaves like VStack
            size.width = maxItemWidth
            size.height = maxItemHeight * CGFloat(subviews.count)
        } else if let proposalWidth = proposal.width {
            // For exact size, use "staggered" style
            size.width = ceil(min(proposalWidth, widthInOneLine))
            let w = size.width
            
            var availableW = w
            var accHeight = maxItemHeight
            
            for subView in subviews {
                let vW = subView.sizeThatFits(.unspecified).width
                
                if availableW >= vW {
                    availableW -= vW
                } else {
                    availableW = w - vW
                    accHeight += maxItemHeight
                }
            }
            
            size.height = accHeight
        }
        
        return size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxItemHeight = subviews.map { v in
            v.sizeThatFits(.unspecified).height
        }.max() ?? 0
                
        // Start positioning by the origin point, which should not be assumed to (0,0)
        var currentPosition = bounds.origin
        
        for subView in subviews {
            let d = subView.sizeThatFits(.unspecified)
            
            if currentPosition.x + d.width <= bounds.maxX {
                // If the current line can fit the item, we place it in this line and consume the available width
                subView.place(at: currentPosition, proposal: .unspecified)
                currentPosition.x = currentPosition.x + d.width
            } else {
                // The item does not fit the current line, we break the line
                currentPosition.x = bounds.minX
                currentPosition.y = currentPosition.y + maxItemHeight
                
                subView.place(at: currentPosition, proposal: .unspecified)
                
                // Always to consume the x position after place(at:proposal)
                currentPosition.x = currentPosition.x + d.width
            }
        }
    }
    
    private func computeSpaces(subviews: LayoutSubviews) -> [CGFloat] {
        return subviews.indices.map { idx in
            guard idx < subviews.count - 1 else { return CGFloat(0) }
            return subviews[idx].spacing.distance(to: subviews[idx + 1].spacing, along: .horizontal)
        }
    }
}
