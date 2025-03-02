//
//  ArrayExtensions.swift
//  PhotonCam
//
//  Created by Photon Juniper on 2024/3/10.
//

import Foundation

public extension Array {
    /// Split this array into the chunks with ``maxLength``.
    /// - parameter maxLength: The maximum length of each chunk. Must be greater than 0.
    func splitIntoChunks(of maxLength: Int) -> [[Element]] {
        if maxLength == 0 {
            return []
        }
        
        var result = [[Element]]()
        var startIndex = self.startIndex
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: maxLength, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = Array(self[startIndex..<endIndex])
            result.append(chunk)
            startIndex = endIndex
        }
        
        return result
    }
}
