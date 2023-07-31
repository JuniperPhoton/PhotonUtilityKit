//
//  MainViewModel.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI

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
