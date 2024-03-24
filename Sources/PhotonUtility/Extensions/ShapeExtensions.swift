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

public extension CGRect {
    func largestAspectFitRect(of aspectRatio: CGSize) -> CGRect {
        // Calculate aspect ratios
        let originalAspectRatio = self.width / self.height
        let targetAspectRatio = aspectRatio.width / aspectRatio.height
        
        // Determine the maximum size of the new CGRect
        var fitRect: CGRect = .zero
        
        if targetAspectRatio > originalAspectRatio {
            // Width is the limiting factor, so match the width and scale the height
            fitRect.size.width = self.width
            fitRect.size.height = self.width / targetAspectRatio
        } else {
            // Height is the limiting factor, so match the height and scale the width
            fitRect.size.height = self.height
            fitRect.size.width = self.height * targetAspectRatio
        }
        
        // Center the new CGRect within the original CGRect
        fitRect.origin.x = self.origin.x + (self.width - fitRect.width) / 2
        fitRect.origin.y = self.origin.y + (self.height - fitRect.height) / 2
        
        return fitRect
    }
}
