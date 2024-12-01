//
//  OsType+ToString.swift
//  PhotonUtilityKit
//
//  Created by JuniperPhoton on 2024/12/1.
//

import CoreFoundation

public extension OSType {
    /// Get the string representation of the OSType.
    ///
    /// - parameter ostype: The OSType to convert.
    ///
    /// - returns: The string representation of the OSType. If the OSType is not a valid 4-byte ASCII string, nil is returned.
    func ostypeToString() -> String? {
        let bytes = [
            UInt8((self >> 24) & 0xFF),
            UInt8((self >> 16) & 0xFF),
            UInt8((self >> 8) & 0xFF),
            UInt8(self & 0xFF)
        ]
        
        return String(bytes: bytes, encoding: .ascii)
    }
}
