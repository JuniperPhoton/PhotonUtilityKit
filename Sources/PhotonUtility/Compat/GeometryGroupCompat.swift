//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/9/14.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func geometryGroupCompat() -> some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            self.geometryGroup()
        } else {
            self
        }
    }
}
