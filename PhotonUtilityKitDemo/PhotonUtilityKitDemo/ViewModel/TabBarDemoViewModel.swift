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
                         backgroundStyle: .accentColor.opacity(0.1),
                         textKeyPath: \\.rawValue)
    """)
    
    let appSegmentTabBarCode = HighliableCode(code:
    """
        AppSegmentTabBar(selection: $selected, sources: tabs,
                         scrollable: false,
                         foregroundColor: .accentColor,
                         backgroundStyle: .accentColor.opacity(0.1),
                         horizontalInset: 0) { tab in
            HStack {
                Image(systemName: tab.icon)
                Text(tab.rawValue.uppercased()).bold()
            }.foregroundColor(tab == selected ? .white : .accentColor).padding(8)
        }
    """)
}
