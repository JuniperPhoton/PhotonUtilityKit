//
//  File.swift
//
//
//  Created by Photon Juniper on 2024/3/27.
//
import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins

public extension CIImage {
    /// Get the color inverted image.
    func colorInverted() -> CIImage? {
        return self.applyFilter(CIFilter.colorInvert())
    }
    
    /// Get the color clamped image.
    func colorClamped() -> CIImage? {
        return self.applyFilter(CIFilter.colorClamp())
    }
    
    /// Apply a filter, configure the parameters of this filter and return the output image.
    /// This method provides an easy way to chain your filter.
    ///
    /// Given an input image, to apply a filter:
    ///
    /// ```swift
    /// let outputImage = inputImage.applyFilter(CIFilter.colorMatrix()) { filter in
    ///     // Configure colorMatrix filter.
    ///     // Input image will be set automatically.
    /// }
    /// ```
    ///
    /// - clampedToExtent: Convenient option to set the input clampedToExtent and then crop the output to the original extent.
    func applyFilter<T: CIFilter>(
        _ filter: T,
        clampedToExtent: Bool = false,
        transform: ((T) -> Void)? = nil
    ) -> CIImage? {
        let filter = filter
        transform?(filter)
        
        var input = self
        
        let originalExtent = self.extent
        if clampedToExtent {
            input = self.clampedToExtent()
        }
        
        filter.setValue(input, forKey: kCIInputImageKey)
        
        let output = filter.outputImage
        if clampedToExtent {
            return output?.cropped(to: originalExtent)
        } else {
            return output
        }
    }
}

public extension CIImage {
    /// Get the underlaying pixelBuffer of this ``CIImage`` or create a new one to a preferredFormat.
    ///
    /// If you would like to always create a new ``CVPixelBuffer``, use ``createCVPixelBuffer(ciContext:preferredFormat:)``.
    ///
    /// - parameter ciContext: The CIContext to use when creating a new ``CVPixelBuffer``.
    /// - parameter preferredFormat: The preferred pixel format when creating a new ``CVPixelBuffer``.
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
    
    /// Create a new ``CVPixelBuffer`` from this image.
    /// - parameter ciContext: The CIContext to use.
    /// - parameter preferredFormat: The preferred pixel format.
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
