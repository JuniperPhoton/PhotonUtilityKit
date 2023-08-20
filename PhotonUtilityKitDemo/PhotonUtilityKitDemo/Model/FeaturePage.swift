//
//  FeaturePage.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/31.
//

import Foundation
import SwiftUI

enum FeaturePage: String, FeaturePageTrait {
    case unevenRoundedRectangle = "Uneven Rounded Rect"
    case animatableGradient = "Animatable Gradient"
    case animatableNumber = "Animatable Number"
    case actionButton = "Action button"
    case tips = "Tips"
    case toast = "Toast"
    case appSegmentTabBar = "Tab bar"
    case fullscreenContent = "Fullscreen content"
    case staggeredGrid = "Staggered Grid"
    case iconGenerator = "Icon Generator"
    case screenshot = "Screenshot"
    case bridgedPageView = "Bridged PageView"

    var icon: String {
        switch self {
        case .unevenRoundedRectangle:
            return "rectangle"
        case .animatableNumber:
            return "number"
        case .bridgedPageView:
            return "book"
        case .animatableGradient:
            return "square.stack.3d.down.right"
        case .actionButton:
            return "hammer"
        case .tips:
            return "bubble.middle.top"
        case .toast:
            return "hammer"
        case .appSegmentTabBar:
            return "menubar.rectangle"
        case .fullscreenContent:
            return "hammer"
        case .staggeredGrid:
            return "grid"
        case .iconGenerator:
            return "viewfinder"
        case .screenshot:
            return "macwindow"
        }
    }

    var supportedPlatforms: [Platform] {
        switch self {
        case .iconGenerator, .screenshot:
            return [.macOS]
        default:
            return Platform.allCases
        }
    }
}

extension FeaturePage {
    @ViewBuilder
    var viewBody: some View {
        switch self {
        case .unevenRoundedRectangle:
            UnevenRoundedRectDemoView()
        case .animatableNumber:
            AnimatedNumberDemoView()
        case .tips:
            TipsDemoView()
        case .bridgedPageView:
            BridgedPageViewDemoView()
        case .animatableGradient:
            AnimatableGradientDemoView()
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
        case .screenshot:
            ScreenshotDemoView()
        }
    }
}
