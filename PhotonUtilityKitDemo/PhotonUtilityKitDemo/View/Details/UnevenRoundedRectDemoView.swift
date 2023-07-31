//
//  UnevenRoundedRectDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/25.
//

import PhotonUtility
import PhotonUtilityView
import SwiftUI

struct UnevenRoundedRectDemoView: View {
    private let code = HighliableCode(code: """
    Text("UnevenRoundedRectangleView")
        .padding()
        .background(
            UnevenRoundedRectangle(top: 12, bottom: 0).fill(.gray.opacity(0.1))
        )
    """)

    var body: some View {
        VStack {
            HighliableCodeView(code: code)
            
            Text("UnevenRoundedRectangleView")
                .padding()
                .background(
                    UnevenRoundedRectangle(top: 12, bottom: 0).fill(.gray.opacity(0.1))
                )
        }
        .padding()
        .matchParent()
        .navigationTitle("UnevenRoundedRect")
    }
}
