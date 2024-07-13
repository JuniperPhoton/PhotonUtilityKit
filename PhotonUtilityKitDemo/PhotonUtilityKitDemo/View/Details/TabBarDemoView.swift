//
//  TabBarDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2024/4/5.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

struct TabBarDemoView: View {
    @StateObject private var viewModel = TabBarDemoViewModel()
    
    @State private var tabs = Tabs.allCases
    @State private var selected = Tabs.cursive
    @State private var showSheet = false
    
    var body: some View {
#if !os(tvOS)
        VStack {
            Text("TextAppSegmentTabBar").applySubTitle()
            
            HighliableCodeView(code: viewModel.textAppSegmentTabBarCode)
            
            TextAppSegmentTabBar(
                selection: $selected.animation(.default.speed(1.3)),
                sources: tabs,
                scrollable: false,
                foregroundColor: .accentColor,
                backgroundStyle: .accentColor.opacity(0.1),
                textKeyPath: \.rawValue
            )
            
            Spacer().frame(height: 50)
            
            Text("AppSegmentTabBar").applySubTitle()
            
            HighliableCodeView(code: viewModel.appSegmentTabBarCode)
            
            AppSegmentTabBar(
                selection: $selected.animation(.default.speed(1.3)),
                sources: tabs,
                scrollable: true,
                foregroundColor: .accentColor,
                backgroundStyle: .accentColor.opacity(0.1),
                horizontalInset: 0,
                shape: Capsule()
            ) { tab in
                HStack {
                    Image(systemName: tab.icon)
                    Text(tab.rawValue.uppercased()).bold()
                }.foregroundColor(tab == selected ? .white : .accentColor).padding(8)
            }
        }
        .matchHeight(.topLeading)
        .padding()
        .navigationTitle("TabBar")
        .toolbar {
            Button("ShowSheet") {
                showSheet.toggle()
            }
        }
        .sheetCompat(isPresented: $showSheet) {
            Text("A sheet")
        }
#else
        NotSupportedHintView(notSupportedPlatforms: [.tvOS])
#endif
    }
}
