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
        case .iconGenerator:
            IconGeneratorView()
        }
    }
}
