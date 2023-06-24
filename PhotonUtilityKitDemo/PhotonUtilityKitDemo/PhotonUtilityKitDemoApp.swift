//
//  PhotonUtilityKitDemoApp.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI

@main
struct PhotonUtilityKitDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
#if os(macOS)
                .frame(minWidth: 500, minHeight: 400)
#endif
        }
#if os(macOS)
        .windowStyle(.hiddenTitleBar)
#endif
    }
}
