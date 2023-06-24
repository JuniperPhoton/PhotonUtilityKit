//
//  MainViewModel.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI

enum Catagory: String {
    case customUI = "Custom Views"
    case customLayout = "Custom Layout"
    case handyExtension = "Handy Extensions"
}

enum FeaturePage: String {
    case unevenedRoundedRectangle = "Unevened Rounded Rect"
    case actionButton = "Action button"
    case toast = "Toast"
    case appSegmentTabBar = "Tab bar"
    case fullscreenContent = "Fullscreen content"
    case staggeredGrid = "Staggered Grid"
    
    var icon: String {
        switch self {
        case .unevenedRoundedRectangle:
            return "rectangle"
        case .actionButton:
            return "hammer"
        case .toast:
            return "hammer"
        case .appSegmentTabBar:
            return "menubar.rectangle"
        case .fullscreenContent:
            return "hammer"
        case .staggeredGrid:
            return "grid"
        }
    }
}

struct CatalogyPage: Identifiable {
    let cagatory: Catagory
    let pages: [FeaturePage]
    
    var id: String {
        self.cagatory.rawValue
    }
}

class MainViewModel: ObservableObject {
    @Published var catalogyPages: [CatalogyPage] = []
    @Published var searchText: String = ""
    
    let allCatalogyPages: [CatalogyPage] = [
        CatalogyPage(cagatory: .customUI,
                     pages: [
                        .unevenedRoundedRectangle,
                        .actionButton,
                        .toast,
                        .appSegmentTabBar,
                        .fullscreenContent
                     ]),
        CatalogyPage(cagatory: .customLayout,
                     pages: [
                        .staggeredGrid
                     ]),
    ]
    
    init() {
        catalogyPages = allCatalogyPages
    }
    
    func refresh() {
        if searchText.isEmpty {
            catalogyPages = allCatalogyPages
            return
        }
        
        catalogyPages = []
        allCatalogyPages.forEach { catagory in
            catalogyPages.append(.init(cagatory: catagory.cagatory, pages: catagory.pages.filter({ page in
                page.rawValue.lowercased().contains(searchText.lowercased())
            })))
        }
    }
}
