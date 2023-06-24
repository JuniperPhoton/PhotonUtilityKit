//
//  MainViewModel.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI

enum Catagory: String {
    case customUI = "Custom Views"
    case handyExtension = "Handy Extensions"
}

enum FeaturePage: String {
    case unevenedRoundedRectangle = "Unevened Rounded Rect"
    case actionButton = "Action button"
    case toast = "Toast"
    case appSegmentTabBar = "Tab bar"
}

struct CatalogyPage: Identifiable {
    let cagatory: Catagory
    let pages: [FeaturePage]
    
    var id: String {
        self.cagatory.rawValue
    }
}

class MainViewModel: ObservableObject {
    @Published var catalogyPages: [CatalogyPage] = [
        CatalogyPage(cagatory: .customUI,
                     pages: [.unevenedRoundedRectangle,
                             .actionButton,
                             .toast,
                             .appSegmentTabBar
                     ])
    ]
}
