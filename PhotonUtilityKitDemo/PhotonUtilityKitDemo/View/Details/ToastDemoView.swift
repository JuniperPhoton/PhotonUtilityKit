//
//  ToastDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

struct ToastDemoView: View {
    @StateObject private var appToast = AppToast()
    @State private var toastColor = ToastColor()
    
    @State private var showIcon = true
    
    var body: some View {
        ZStack {
            VStack {
                Text("Click the buttons to show toasts.")
                
                Text("Dismiss").asButton {
                    appToast.clear()
                }.buttonStyle(.bordered)

                Text("With special colors").asButton {
                    toastColor = .init(foregroundColor: Color.red, backgroundColor: Color.red.opacity(0.1))
                    appToast(.constant("With special colors"))
                }
                Text("Hello from toast").asButton {
                    toastColor = ToastColor()
                    appToast(.constant("Hello from toast"))
                }
                Text("Show toast with long text").asButton {
                    toastColor = ToastColor()
                    appToast(.constant("Create engaging SwiftUI Mac apps by incorporating side bars, tables, toolbars, and several other popular user interface elements."))
                }
                
                Toggle("Shows icon", isOn: $showIcon)
                    .padding(.horizontal)
                
                NavigationZStack {
                    CustomContentView()
                }
            }
            
            ToastView(appToast: appToast)
                .toastColors(toastColor)
                .toastShowIcon(showIcon)
        }
        .matchHeight(.topLeading)
        .environmentObject(appToast)
        .navigationTitle("Toast")
    }
}

struct CustomContentView: View {
    @State private var title = "Test"
    
    var body: some View {
        VStack {
            Text("Test")
            Button {
                title = "Changed title"
            } label: {
                Text("Toggle")
            }
        }
        .navigationZStackTitle(title)
    }
}

struct NaivgationTitlePreferenceKey: PreferenceKey {
    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
    
    static var defaultValue: String { "" }
}

extension View {
    func navigationZStackTitle(_ title: String) -> some View {
        self.preference(key: NaivgationTitlePreferenceKey.self, value: title)
    }
}

struct NavigationZStack<V: View>: View {
    var item: () -> V
    
    @State private var title: String = ""
    
    var body: some View {
        VStack {
            if !title.isEmpty {
                Text(title)
                    .font(.largeTitle.bold())
            }
            item()
        }.matchParent()
            .onPreferenceChange(NaivgationTitlePreferenceKey.self) { value in
                self.title = value
            }
    }
}
