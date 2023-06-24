//
//  DetailPage.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView
import Highlightr
import PhotonUtilityLayout

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
        case .fullscreenContent:
            FullscreenContentDemoView()
        case .staggeredGrid:
            StaggeredGridDemoView()
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
        .navigationTitle("UnevenedRoundedRect")
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
            .animation(.easeInOut, value: isLoading)
            
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
        .navigationTitle("ActionButton")
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
        .matchHeight(.topLeading)
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
        .navigationTitle("Toast")
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
            
            TextAppSegmentTabBar(selection: $selected,
                                 sources: tabs,
                                 scrollable: true,
                                 foregroundColor: .accentColor,
                                 backgroundColor: .accentColor.opacity(0.1),
                                 textKeyPath: \.rawValue)
            
            Spacer().frame(height: 50)
            
            Text("AppSegmentTabBar").applySubTitle()
            
            HighliableCodeView(code: viewModel.appSegmentTabBarCode)

            AppSegmentTabBar(selection: $selected, sources: tabs,
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

struct FullscreenContentDemoView: View {
    @StateObject private var fullscreenPresentation = FullscreenPresentation()

    var body: some View {
        ZStack {
            VStack {
                Text(
            """
            Show full-screen content in a specified view.
            
            You can use BottomSheetView as a parent view to display a sheet-based view.
            
            On iOS, BottomSheetView appears as a bottom sheet with a swipe-down gesture, while on macOS, it appears in the center.
            """
                )
                .matchWidth(.leading)
                .padding(.bottom)
                
                VStack(spacing: 20) {
                    Text("Bottom sheet").asButton {
                        let view = BottomSheetView(backgroundColor: .white) {
                            VStack {
                                Text("Bottom sheet title")
                                    .font(.title.bold())
                                    .padding(.bottom)
                                Text("On iOS and iPadOS, you can swipe down to dismiss.")
                                    .multilineTextAlignment(.center)
                            }.matchHeight(.top).frame(maxHeight: 200)
                        }
                        
                        fullscreenPresentation.present(view: view)
                    }.matchWidth(.leading)
                    
                    Text("Custom").asButton {
                        let view = VStack {
                            Text("Custom title")
                                .font(.title.bold())
                                .padding(.bottom)
                            Text("A custom view content. Tap to dismiss.")
                                .multilineTextAlignment(.center)
                        }.matchParent()
                        #if os(iOS)
                            .background(.thinMaterial)
                        #else
                            .background(Color.black.opacity(0.5))
                        #endif
                            .onTapGesture {
                                fullscreenPresentation.dismissAll()
                            }
                        
                        fullscreenPresentation.present(view: view)
                    }.matchWidth(.leading)
                }
            }
            .matchParent(alignment: .topLeading)
            .padding()
            
            fullscreenContent()
        }
        .navigationTitle("Fullscreen content")
        .environmentObject(fullscreenPresentation)
    }
    
    @ViewBuilder
    private func fullscreenContent() -> some View {
        ZStack {
            if let view = fullscreenPresentation.presentedView {
                ZStack {
                    AnyView(view)
                }.matchParent().transition(fullscreenPresentation.transition)
                    .onDisappear {
                        fullscreenPresentation.invokeOnDismiss()
                    }
            }
        }.transaction { current in
            if let override = fullscreenPresentation.transcation {
                current = override
            }
        }
    }
}

struct StaggeredGridDemoView: View {
    @State private var code = HighliableCode(code: """
    StaggeredGrid {
        StaggeredGridContentView(text: "Fish")
        StaggeredGridContentView(text: "Gloomy")
        StaggeredGridContentView(text: "Clutter up")
        StaggeredGridContentView(text: "Poggy")
        StaggeredGridContentView(text: "Rattled")
        StaggeredGridContentView(text: "Fuss")
        StaggeredGridContentView(text: "Cultivate")
    }
    """)
    
    var body: some View {
        VStack {
            Text("StaggeredGrid supports iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0 and above. Try to resize the window to see animations.")
                .padding(.horizontal)
                .matchWidth(.leading)
            
            HighliableCodeView(code: code).padding()

            if #available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *) {
                StaggeredGrid {
                    StaggeredGridContentView(text: "Fish")
                    StaggeredGridContentView(text: "Gloomy")
                    StaggeredGridContentView(text: "Clutter up")
                    StaggeredGridContentView(text: "Poggy")
                    StaggeredGridContentView(text: "Rattled")
                    StaggeredGridContentView(text: "Fuss")
                    StaggeredGridContentView(text: "Cultivate")
                }
                .matchHeight(.top).padding(.horizontal)
            }
        }
        .navigationTitle("Staggered Grid")
    }
}

struct StaggeredGridContentView: View {
    let text: String
    
    var body: some View {
        Text("#\(text)")
            .font(.title2.bold())
            .foregroundColor(Color.accentColor)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.accentColor.opacity(0.1)))
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
    }
}
