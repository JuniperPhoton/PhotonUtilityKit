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
    case iconGenerator = "Icon Generator"
    case screenshot = "Screenshot"
    case bridgedPageView = "Bridged PageView"
    case scrollViewBridge = "ScrollView Bridge"

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
        case .iconGenerator:
            return "viewfinder"
        case .screenshot:
            return "macwindow"
        case .scrollViewBridge:
            return "square.arrowtriangle.4.outward"
        }
    }

    var supportedPlatforms: [Platform] {
        switch self {
        case .iconGenerator, .screenshot:
            return [.macOS]
        case .scrollViewBridge:
            return [.iOS]
        case .appSegmentTabBar:
            return [.iOS, .macOS]
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
        case .iconGenerator:
            IconGeneratorView()
        case .screenshot:
            ScreenshotDemoView()
        case .scrollViewBridge:
            ScrollViewBridgeDemoView()
        }
    }
}
