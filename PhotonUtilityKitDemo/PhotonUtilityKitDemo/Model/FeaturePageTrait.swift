//
//  FeaturePageTrait.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/31.
//

import Foundation

protocol FeaturePageTrait {
    var icon: String { get }
    var supportedPlatforms: [Platform] { get }
}
