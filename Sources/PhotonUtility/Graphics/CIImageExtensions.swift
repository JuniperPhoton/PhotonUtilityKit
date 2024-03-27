//
//  File.swift
//  
//
//  Created by Photon Juniper on 2024/3/27.
//
import Foundation
import CoreImage

public extension CIImage {
    func getOrCreateCVPixelBuffer(
        ciContext: CIContext? = nil,
        preferredFormat: OSType = kCVPixelFormatType_32BGRA
    ) -> CVPixelBuffer? {
        if let pixelBuffer = self.pixelBuffer {
            return pixelBuffer
        } else {
            return createCVPixelBuffer(
                ciContext: ciContext,
                preferredFormat: preferredFormat
            )
        }
    }
    
    func createCVPixelBuffer(
        ciContext: CIContext? = nil,
        preferredFormat: OSType = kCVPixelFormatType_32BGRA
    ) -> CVPixelBuffer? {
        let workingContext = ciContext ?? CIContext()
        // Specify the pixel buffer attributes
        let attributes = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferMetalCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        // Create a pixel buffer at the size of the image
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(self.extent.size.width),
            Int(self.extent.size.height),
            preferredFormat,
            attributes,
            &pixelBuffer
        )
        
        // Check if the pixel buffer creation was successful
        guard status == kCVReturnSuccess, let unwrappedPixelBuffer = pixelBuffer else {
            return nil
        }
        
        workingContext.render(self, to: unwrappedPixelBuffer)
        return pixelBuffer
    }
}
