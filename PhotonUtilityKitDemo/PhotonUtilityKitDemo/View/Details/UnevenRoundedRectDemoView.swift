//
//  UnevenRoundedRectDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

struct UnevenRoundedRectDemoView: View {
    var body: some View {
        VStack {
            Text("UnevenRoundedRectangleView")
                .padding()
                .background(UnevenRoundedRectangle(top: 12, bottom: 0).fill(.gray.opacity(0.1)))
        }
        .matchParent()
        .navigationTitle("UnevenRoundedRect")
    }
}
