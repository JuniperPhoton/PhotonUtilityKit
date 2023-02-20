//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/1/4.
//

import Foundation

public extension CGRect {
    func toString() -> String {
        return "minX: \(minX), minY: \(minY), maxX: \(maxX), maxY: \(maxY), width: \(width), height: \(height)"
    }
}
