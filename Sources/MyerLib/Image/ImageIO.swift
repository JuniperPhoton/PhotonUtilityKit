//
//  ImageIO.swift
//  MyerSplash2
//
//  Created by Photon Juniper on 2023/2/24.
//

import Foundation
import CoreGraphics
import ImageIO

public struct ImageLoadingError: Error {
    
}

public actor ImageIO {
    public static let shared = ImageIO()
    
    private init() {
        // empty
    }
    
    public func loadCGImage(data: Data) async throws -> CGImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageLoadingError()
        }
        
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageLoadingError()
        }
        
        return cgImage
    }
}
