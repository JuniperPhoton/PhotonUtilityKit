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

public extension String {
    /// Convert a string to an OSType.
    func stringToOSType() -> OSType? {
        guard self.count == 4 else {
            print("OSType must be exactly 4 characters long.")
            return nil
        }
        
        var type: OSType = 0
        for (index, char) in self.utf8.enumerated() {
            type |= OSType(char) << (24 - (8 * index))
        }
        
        return type
    }
}
