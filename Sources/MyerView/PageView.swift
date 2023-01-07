//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/1/7.
//

import SwiftUI
import MyerLib

/// Current not used.
public struct PageView<Content: View, C: RandomAccessCollection>: View where C.Element: Identifiable & Equatable {
    let items: C
    let itemContent: (C.Element) -> Content
    let startPageIndex: Int
    
    let disablePaging: Binding<Bool>
    
    var onPageIndexChanged: ((Int) -> Void)? = nil
    
    @GestureState var dragTranslationX: CGFloat = 0
    
    @State var translationX: CGFloat = 0
    @State var virtualPageIndex: CGFloat = 0
    
    @State var displayedItemId: C.Element.ID? = nil {
        didSet {
            if let originalIndex = items.firstIndex(where: { v in
                v.id == displayedItemId
            }) as? Int {
                onPageIndexChanged?(originalIndex)
            }
        }
    }
    
    @State var displayedItems: [C.Element] = []
    @State var width: CGFloat = 0.0
    
    private let offscreenCountPerSide = 1
    private let spacing: CGFloat = 20
    
    public init(items: C, startPageIndex: Int,
                disablePaging: Binding<Bool>,
                onPageIndexChanged: ((Int) -> Void)? = nil,
                @ViewBuilder itemContent: @escaping (C.Element) -> Content) {
        self.items = items
        self.itemContent = itemContent
        self.startPageIndex = startPageIndex
        self.disablePaging = disablePaging
        self.onPageIndexChanged = onPageIndexChanged
        print("dwccc start page index \(startPageIndex), disable paging \(disablePaging)")
    }
    
    private func calculateDisplayItems(originalIndex: Int) {
        displayedItems.removeAll()
        
        var start = originalIndex - 1
        if start < 0 {
            start = 0
        }
        var end = start + offscreenCountPerSide * 2
        if end >= items.count {
            end = items.count - 1
        }
        for i in start...end {
            if let index = items.index(items.startIndex, offsetBy: i, limitedBy: items.endIndex) {
                displayedItems.append(items[index])
            }
        }
        
        print("dwccc calculateDisplayItems \(start)...\(end), virtualPageIndex \(virtualPageIndex), current input \(originalIndex)")
    }
    
    public var body: some View {
        let gesture = DragGesture()
            .onEnded { value in
                onGestureEnd(value: value)
            }
            .updating($dragTranslationX) { v, state, _ in
                state = v.translation.width
            }
        
        GeometryReader { proxy in
            HStack(spacing: spacing) {
                ForEach(displayedItems, id: \.id) { item in
                    itemContent(item)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .matchParent()
            .offset(x: (-CGFloat(virtualPageIndex) * (proxy.size.width + spacing)) + translationX)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(gesture, including: disablePaging.wrappedValue ? .subviews : .all)
        .onAppear {
            calculateDisplayItems(originalIndex: startPageIndex)
            updateVirtualPageIndex(originalIndex: startPageIndex)
        }
        .onChange(of: dragTranslationX) { newValue in
            translationX = newValue
        }
        .listenWidthChanged { width in
            self.width = width
        }
    }
    
    private func onGestureEnd(value: DragGesture.Value) {
        let duration = 0.3
        let scrollSlop: CGFloat = 20
        
        withEastOutAnimation(duration: duration) {
            var newIndex = virtualPageIndex
            if translationX > scrollSlop {
                var index = virtualPageIndex - 1
                if index < 0 {
                    index = 0
                }
                newIndex = index
            } else if translationX < -scrollSlop {
                var index = virtualPageIndex + 1
                if index >= CGFloat(displayedItems.count) {
                    index = CGFloat(displayedItems.count) - 1
                }
                newIndex = index
            }
            
            print("dwccc on gesture end newIndex: \(newIndex), from virtualPageIndex \(virtualPageIndex)")
            
            self.virtualPageIndex = newIndex
            self.translationX = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                let currentItem = displayedItems[Int(self.virtualPageIndex)]
                let originalIndex = items.firstIndex { id in
                    id == currentItem
                } as! Int
                
                withEastOutAnimation(duration: duration) {
                    calculateDisplayItems(originalIndex: originalIndex)
                    updateVirtualPageIndex(originalIndex: originalIndex)
                }
            }
        }
    }
    
    private func updateVirtualPageIndex(originalIndex: Int) {
        if originalIndex != 0 && originalIndex != items.count - 1  {
            virtualPageIndex = 1
        } else if originalIndex == 0 {
            virtualPageIndex = 0
        } else if originalIndex == items.count - 1 {
            virtualPageIndex = CGFloat(displayedItems.count) - 1
        }
        
        displayedItemId = displayedItems[Int(virtualPageIndex)].id
    }
}
