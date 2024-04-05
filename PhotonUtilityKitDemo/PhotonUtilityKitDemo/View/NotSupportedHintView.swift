//
//  NotSupportedHintView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2024/4/5.
//

import SwiftUI

struct NotSupportedHintView: View {
    let notSupportedPlatforms: [Platform]
    
    var body: some View {
        Text("Not supported in the following platforms: \(notSupportedPlatforms.joinToString { $0.rawValue })")
    }
}
