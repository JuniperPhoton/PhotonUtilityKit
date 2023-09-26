//
//  TabBarDemoViewModel.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

enum Tabs: String, Hashable, CaseIterable {
    case pencil
    case cursive
    case ferry
    case person
    
    var icon: String {
        switch self {
        case .pencil:
            return "pencil"
        case .cursive:
            return "f.cursive.circle"
        case .ferry:
            return "ferry"
        case .person:
            return "person"
        }
    }
}

class TabBarDemoViewModel: ObservableObject {
    let textAppSegmentTabBarCode = HighliableCode(code:
    """
    TextAppSegmentTabBar(selection: $selected,
                         sources: tabs,
                         scrollable: false,
                         foregroundColor: .accentColor,
                         backgroundColor: .accentColor.opacity(0.1),
                         textKeyPath: \\.rawValue)
    """)
    
    let appSegmentTabBarCode = HighliableCode(code:
    """
        AppSegmentTabBar(selection: $selected, sources: tabs,
                         scrollable: false,
                         foregroundColor: .accentColor,
                         backgroundColor: .accentColor.opacity(0.1),
                         horizontalInset: 0) { tab in
            HStack {
                Image(systemName: tab.icon)
                Text(tab.rawValue.uppercased()).bold()
            }.foregroundColor(tab == selected ? .white : .accentColor).padding(8)
        }
    """)
}

struct TabBarDemoView: View {
    @StateObject private var viewModel = TabBarDemoViewModel()
    
    @State private var tabs = Tabs.allCases
    @State private var selected = Tabs.cursive
    
    var body: some View {
        VStack {
            Text("TextAppSegmentTabBar").applySubTitle()
            
            HighliableCodeView(code: viewModel.textAppSegmentTabBarCode)
            
            TextAppSegmentTabBar(selection: $selected.animation(.default.speed(1.3)),
                                 sources: tabs,
                                 scrollable: true,
                                 foregroundColor: .accentColor,
                                 backgroundColor: .accentColor.opacity(0.1),
                                 textKeyPath: \.rawValue)
            
            Spacer().frame(height: 50)
            
            Text("AppSegmentTabBar").applySubTitle()
            
            HighliableCodeView(code: viewModel.appSegmentTabBarCode)

            AppSegmentTabBar(selection: $selected.animation(.default.speed(1.3)), sources: tabs,
                             scrollable: true,
                             foregroundColor: .accentColor,
                             backgroundColor: .accentColor.opacity(0.1),
                             horizontalInset: 0) { tab in
                HStack {
                    Image(systemName: tab.icon)
                    Text(tab.rawValue.uppercased()).bold()
                }.foregroundColor(tab == selected ? .white : .accentColor).padding(8)
            }
        }
        .matchHeight(.topLeading)
        .padding()
        .navigationTitle("TabBar")
    }
}
