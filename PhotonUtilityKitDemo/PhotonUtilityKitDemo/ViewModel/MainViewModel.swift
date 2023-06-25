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
    case utility = "Utility"
}

enum Platform: String, CaseIterable, Hashable {
    case iOS
    case macOS
    
    static func currentPlatform() -> [Platform] {
        var platforms: [Platform] = []
        #if os(iOS)
        platforms.append(.iOS)
        #elseif os(macOS)
        platforms.append(.macOS)
        #endif
        return platforms
    }
}

protocol FeaturePageTrait {
    var icon: String { get }
    var supportedPlatforms: [Platform] { get }
}

enum FeaturePage: String, FeaturePageTrait {
    case unevenedRoundedRectangle = "Unevened Rounded Rect"
    case actionButton = "Action button"
    case toast = "Toast"
    case appSegmentTabBar = "Tab bar"
    case fullscreenContent = "Fullscreen content"
    case staggeredGrid = "Staggered Grid"
    case iconGenerator = "Icon Generator"
    
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
        case .iconGenerator:
            return "viewfinder"
        }
    }
    
    var supportedPlatforms: [Platform] {
        switch self {
        case .iconGenerator:
            return [.macOS]
        default:
            return Platform.allCases
        }
    }
}

struct CatalogyPage: Identifiable {
    let cagatory: Catagory
    let pages: [FeaturePage]
    
    var id: String {
        self.cagatory.rawValue
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
                        .unevenedRoundedRectangle,
                        .actionButton,
                        .toast,
                        .appSegmentTabBar,
                        .fullscreenContent
                     ]),
        CatalogyPage(.customLayout, [.staggeredGrid]),
        CatalogyPage(.utility, [.iconGenerator])
    ].filter { c in
        !c.isEmpty
    }
}

class MainViewModel: ObservableObject {
    @Published var catalogyPages: [CatalogyPage] = []
    @Published var searchText: String = ""
    
    let allCatalogyPages: [CatalogyPage]
    
    init() {
        allCatalogyPages = generateAllCatagories()
        catalogyPages = allCatalogyPages
    }
    
    func filterBySearchText() {
        if searchText.isEmpty {
            catalogyPages = allCatalogyPages
            return
        }
        
        catalogyPages = []
        
        allCatalogyPages.forEach { catagory in
            catalogyPages.append(.init(catagory.cagatory, catagory.pages.filter { page in
                page.rawValue.lowercased().contains(searchText.lowercased())
            }))
        }
    }
}
