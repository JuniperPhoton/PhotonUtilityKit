//
//  Platform.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/31.
//

import Foundation

enum Platform: String, CaseIterable, Hashable {
    case iOS
    case macOS
    case tvOS

    static func currentPlatform() -> [Platform] {
        var platforms: [Platform] = []
        #if os(iOS)
            platforms.append(.iOS)
        #elseif os(macOS)
            platforms.append(.macOS)
        #elseif os(tvOS)
            platforms.append(.tvOS)
        #endif
        return platforms
    }
}
