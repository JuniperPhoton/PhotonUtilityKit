//
//  Styles.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI

extension View {
    func applySubTitle() -> some View {
        self.matchWidth(.leading)
            .font(.title3.bold())
    }
}
