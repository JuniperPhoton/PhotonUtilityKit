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
            }
            
            ToastView(appToast: appToast, colors: toastColor)
        }
        .matchHeight(.topLeading)
        .environmentObject(appToast)
        .navigationTitle("Toast")
    }
}
