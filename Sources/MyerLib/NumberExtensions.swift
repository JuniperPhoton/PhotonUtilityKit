//
//  NumberExtensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/24.
//

import Foundation

public extension Int {
    /// Convert a second to nanosecond.
    func secToNanoSec() -> UInt64 {
        return UInt64(self * 1000 * 1000 * 1000)
    }
}

public extension Double {
    /// Convert a second to nanosecond.
    func secToNanoSec() -> UInt64 {
        return UInt64(self * 1000 * 1000 * 1000)
    }
}
