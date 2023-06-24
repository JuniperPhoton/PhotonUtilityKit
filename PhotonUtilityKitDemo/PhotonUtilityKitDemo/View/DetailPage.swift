//
//  DetailPage.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

extension FeaturePage {
    @ViewBuilder
    var viewBody: some View {
        switch self {
        case .unevenedRoundedRectangle:
            UnevenedRoundedRectDemoView()
        case .actionButton:
            ActionButtonDemoView()
        case .toast:
            ToastDemoView()
        case .appSegmentTabBar:
            TabBarDemoView()
        }
    }
}

struct UnevenedRoundedRectDemoView: View {
    var body: some View {
        VStack {
            Text("UnevenedRoundedRectangleView")
                .padding()
                .background(UnevenRoundedRectangle(top: 12, bottom: 0).fill(.gray.opacity(0.1)))
        }
        .matchParent()
    }
}

struct ActionButtonDemoView: View {
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            ActionButton(icon: "play",
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)))
            ActionButton(title: "Play", icon: "play",
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)))
            ActionButton(title: "Play", icon: "play",
                         isLoading: $isLoading,
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)))
            ActionButton(title: "Play", icon: "play",
                         style: .init(foregroundColor: .accentColor, backgroundColor: .accentColor.opacity(0.1)),
                         frameConfigration: .init(true))
            .padding(.horizontal)
        }
        .matchWidth()
        .toolbar {
            ToolbarItem {
                Text("Toggle loading").asButton {
                    self.isLoading.toggle()
                }
            }
        }
    }
}

struct ToastDemoView: View {
    @StateObject private var appToast = AppToast()
    @State private var toastColor = ToastColor()
    
    var body: some View {
        ZStack {
            Text("Click the toolbar button to show toasts.")
            
            ToastView(appToast: appToast, colors: toastColor)
        }
        .environmentObject(appToast)
        .toolbar {
            ToolbarItem {
                Text("With special colors").asButton {
                    toastColor = .init(foregroundColor: Color.red, backgroundColor: Color.red.opacity(0.1))
                    appToast(.constant("With special colors"))
                }
            }
            
            ToolbarItem {
                Text("Hello from toast").asButton {
                    toastColor = ToastColor()
                    appToast(.constant("Hello from toast"))
                }
            }
            
            ToolbarItem {
                Text("Show toast with long text").asButton {
                    toastColor = ToastColor()
                    appToast(.constant("Create engaging SwiftUI Mac apps by incorporating side bars, tables, toolbars, and several other popular user interface elements."))
                }
            }
        }
    }
}

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

struct TabBarDemoView: View {
    @State private var tabs = Tabs.allCases
    @State private var selected = Tabs.cursive
    
    var body: some View {
        VStack {
            Text("TextAppSegmentTabBar")
            TextAppSegmentTabBar(selection: $selected,
                                 sources: tabs,
                                 scrollable: false,
                                 foregroundColor: .accentColor,
                                 backgroundColor: .accentColor.opacity(0.1),
                                 textKeyPath: \.rawValue)
            
            Spacer().frame(height: 20)
            
            Text("AppSegmentTabBar")
            
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
        }
    }
}
