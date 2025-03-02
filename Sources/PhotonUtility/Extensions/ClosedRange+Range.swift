//
//  ClosedRangeExtensions.swift
//  PhotonCam
//
//  Created by Photon Juniper on 2024/1/19.
//

import Foundation

public extension ClosedRange where Bound: Numeric {
    var totalRange: Bound {
        upperBound - lowerBound
    }
}
