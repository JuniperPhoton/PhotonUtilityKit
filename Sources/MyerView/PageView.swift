//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/1/7.
//

import SwiftUI
import MyerLib

public struct PagingTranslation: CustomStringConvertible, Equatable {
    let currentIndex: Int
    let nextIndex: Int
    let progress: CGFloat
    
    public init(currentIndex: Int, nextIndex: Int, progress: CGFloat) {
        self.currentIndex = currentIndex
        self.nextIndex = nextIndex
        self.progress = progress
    }
    
    public var description: String {
        return "\(currentIndex) -> \(nextIndex), Progress: \(progress)"
    }
}

/// Current not used.
public struct PageView<Content: View, C: RandomAccessCollection>: View where C.Element: Identifiable & Equatable {
    let items: C
    let itemContent: (C.Element) -> Content
    let pageIndex: Binding<Int>
    
    let disablePaging: Binding<Bool>
    
    var onPageTranslationChanged: ((PagingTranslation) -> Void)? = nil
    
    @GestureState var dragTranslationX: CGFloat = 0
    
    @State var translationX: CGFloat = 0
    @State var virtualPageIndex: CGFloat = 0
    
    @State var displayedItemId: C.Element.ID? = nil {
        didSet {
            if let originalIndex = items.firstIndex(where: { v in
                v.id == displayedItemId
            }) as? Int {
                pageIndex.wrappedValue = originalIndex
            }
        }
    }
    
    @State var displayedItems: [C.Element] = []
    @State var width: CGFloat = 0.0
    
    private let offscreenCountPerSide: Int
    private let spacing: CGFloat
    private let scrollSlop: CGFloat
    private let animationDuration: CGFloat
    
    public init(items: C,
                pageIndex: Binding<Int>,
                disablePaging: Binding<Bool>,
                offscreenCountPerSide: Int = 2,
                spacing: CGFloat = 20,
                scrollSlop: CGFloat = 20,
                animationDuration: CGFloat = 0.3,
                onPageTranslationChanged: ((PagingTranslation) -> Void)? = nil,
                @ViewBuilder itemContent: @escaping (C.Element) -> Content) {
        self.items = items
        self.itemContent = itemContent
        self.pageIndex = pageIndex
        self.disablePaging = disablePaging
        self.offscreenCountPerSide = offscreenCountPerSide
        self.spacing = spacing
        self.scrollSlop = scrollSlop
        self.animationDuration = animationDuration
        self.onPageTranslationChanged = onPageTranslationChanged
        print("dwccc start page index \(pageIndex), disable paging \(disablePaging)")
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
            calculateDisplayItems(originalIndex: pageIndex.wrappedValue)
            updateVirtualPageIndex(originalIndex: pageIndex.wrappedValue)
        }
        .onChange(of: dragTranslationX) { newValue in
            translationX = newValue
            
            let progress: CGFloat = abs(translationX) / self.width
            if progress == 0 {
                return
            }
            
            let currentIndex = pageIndex.wrappedValue
            var nextIndex = translationX < 0 ? currentIndex + 1 : currentIndex - 1
            nextIndex = nextIndex.clamp(to: 0...items.count - 1)
            
            
            let translation = PagingTranslation(currentIndex: currentIndex,
                                                nextIndex: nextIndex, progress: progress)
            self.onPageTranslationChanged?(translation)
        }
        .onChange(of: pageIndex.wrappedValue, perform: { newValue in
            withEastOutAnimation(duration: animationDuration) {
                updateVirtualPageIndex(originalIndex: newValue)
            }
        })
        .listenWidthChanged { width in
            self.width = width
        }
    }
    
    private func onGestureEnd(value: DragGesture.Value) {
        withEastOutAnimation(duration: animationDuration) {
            var newVirtualIndex = virtualPageIndex
            if translationX > scrollSlop {
                var index = virtualPageIndex - 1
                if index < 0 {
                    index = 0
                }
                newVirtualIndex = index
            } else if translationX < -scrollSlop {
                var index = virtualPageIndex + 1
                if index >= CGFloat(displayedItems.count) {
                    index = CGFloat(displayedItems.count) - 1
                }
                newVirtualIndex = index
            }
            
            print("dwccc on gesture end newVirtualIndex: \(newVirtualIndex), from virtualPageIndex \(virtualPageIndex)")
            
            self.virtualPageIndex = newVirtualIndex
            self.translationX = 0
            
            let currentItem = displayedItems[Int(self.virtualPageIndex)]
            let nextOriginalIndex = items.firstIndex { id in
                id == currentItem
            } as! Int
            
            let translation = PagingTranslation(currentIndex: pageIndex.wrappedValue,
                                                nextIndex: nextOriginalIndex, progress: 1.0)
            
            self.onPageTranslationChanged?(translation)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                withEastOutAnimation(duration: animationDuration) {
                    calculateDisplayItems(originalIndex: nextOriginalIndex)
                    updateVirtualPageIndex(originalIndex: nextOriginalIndex)
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
