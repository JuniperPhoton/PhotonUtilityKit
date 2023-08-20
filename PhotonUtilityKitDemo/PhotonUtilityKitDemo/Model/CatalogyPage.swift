//
//  CatalogyPage.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/31.
//

import Foundation

struct CatalogyPage: Identifiable {
    let cagatory: Catagory
    let pages: [FeaturePage]

    var id: String {
        cagatory.rawValue
    }

    var isEmpty: Bool {
        return pages.isEmpty
    }

    init(_ cagatory: Catagory, _ pages: [FeaturePage]) {
        let currentPlatforms = Platform.currentPlatform()

        self.cagatory = cagatory
        self.pages = pages.filter { page in
            page.supportedPlatforms.first { platform in
                currentPlatforms.contains(platform)
            } != nil
        }
    }
}

func generateAllCatagories() -> [CatalogyPage] {
    return [
        CatalogyPage(.customUI,
                     [
                         .unevenRoundedRectangle,
                         .bridgedPageView,
                         .animatableGradient,
                         .animatableNumber,
                         .actionButton,
                         .tips,
                         .toast,
                         .appSegmentTabBar,
                         .fullscreenContent,
                     ]),
        CatalogyPage(.customLayout, [.staggeredGrid]),
        CatalogyPage(.utility, [.screenshot]),
        CatalogyPage(.utilityTools, [.iconGenerator]),
    ].filter { c in
        !c.isEmpty
    }
}
