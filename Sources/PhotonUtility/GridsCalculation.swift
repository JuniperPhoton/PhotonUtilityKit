//
//  GridsCalculation.swift
//  PhotonCam
//
//  Created by Photon Juniper on 2023/12/31.
//

import Foundation
import SwiftUI

public func calculateGridColumns(rootWidth: CGFloat) -> [GridItem] {
    let minSize: Int = 150
    return calculateGridColumns(minSize: minSize, rootWidth: rootWidth)
}

public func calculateGridColumns(minSize: Int, rootWidth: CGFloat) -> [GridItem] {
    var grids: [GridItem] = []
    
    let count = Int(rootWidth) / minSize
    
    for _ in 0...count {
        grids.append(GridItem(.flexible()))
    }
    
    return grids
}
