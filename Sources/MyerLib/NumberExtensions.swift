//
//  NumberExtensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/24.
//

import Foundation

public extension Int {
    func secToNanoSec() -> UInt64 {
        return UInt64(self * 1000 * 1000 * 1000)
    }
}

public extension Double {
    func secToNanoSec() -> UInt64 {
        return UInt64(self * 1000 * 1000 * 1000)
    }
}
