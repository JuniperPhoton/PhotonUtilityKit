//
//  BridgedPageViewDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/25.
//

import SwiftUI
import PhotonUtilityView
import PhotonUtility

struct BridgedPageViewDemoView: View {
    @State private var selectedIndex = 0
    @State private var items = [PageItem]()
    
    @State private var showCode = false
    
    var body: some View {
        VStack {
            if !items.isEmpty {
                Text("On Mac, uses trackpad to scroll horizontally. \nOn touch devices, uses touch to swipe between items. \nOn AppleTV, use arrow key to switch between items.")
                    .matchWidth(.leading)
                    .padding()
                    .padding(.horizontal)
                                
                BridgedPageView(selection: $selectedIndex.easeOutAnimation(), pageObjects: items, idKeyPath: \.id) { item in
                    VStack {
                        Text(item.content)
                            .font(.largeTitle.bold())
                            .matchWidth(.leading)
                        Rectangle().fill(.gray.opacity(0.2)).frame(width: 20, height: 2)
                            .matchWidth(.leading)
                        
                        HighliableCodeView(code: .init(code:
                        #"""
                        BridgedPageView(selection: $selectedIndex.easeOutAnimation(), pageObjects: items, idKeyPath: \.id) { item in
                            VStack(spacing: 0) {
                                Text(item.content)
                                    .font(.largeTitle.bold())
                                    .matchWidth(.leading)
                                Rectangle().fill(.gray.opacity(0.2)).frame(width: 20, height: 2)
                                    .matchWidth(.leading)
                            }
                        }
                        """#), maxHeight: 300).padding(.top)
                        
                        Spacer()
                    }.padding()
                        .matchParent()
                        .background(RoundedRectangle(cornerRadius: 12).fill(.gray.opacity(0.1)))
                        .padding()
                }.padding()
            }
            
            IndicatorView(selectedIndex: $selectedIndex, count: items.count, foregroundColor: .accentColor)
                .padding()
        }.matchParent()
            .navigationTitle("BridgedPageView")
            .onAppear {
                for i in 0..<10 {
                    items.append(PageItem(content: String(i)))
                }
            }
    }
}

fileprivate struct PageItem: Hashable, Identifiable {
    let content: String
    
    var id: String {
        self.content
    }
}
