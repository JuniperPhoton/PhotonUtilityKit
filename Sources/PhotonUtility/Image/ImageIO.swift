//
//  ImageIO.swift
//  MyerSplash2
//
//  Created by Photon Juniper on 2023/2/24.
//

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

public struct ImageIOError: Error {
    let message: String
    
    init(_ message: String = "") {
        self.message = message
    }
}

/// Provides common methods to use about processing image data.
/// You use the ``shared`` to  get the shared instance.
/// The instance is an Swift actor, so all the method is isolated inside this actor, therefore, you must await the methods to complete.
public actor ImageIO {
    public static let shared = ImageIO()
    
    private init() {
        // empty
    }
    
    /// Load the data as ``CGImage``.
    /// - parameter data: data to be loaded as ``CGImage``
    public func loadCGImage(data: Data) throws -> CGImage {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageIOError("Failed to create image source")
        }
        
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageIOError("Faile")
        }
        
        return cgImage
    }
    
    /// Scale image to the specified factor.
    public func scaleCGImage(image: CGImage, scaleFactor: CGFloat) -> CGImage? {
        let rect = CGRect(x: 0, y: 0, width: CGFloat(image.width) * scaleFactor,
                          height: CGFloat(image.height) * scaleFactor)
        
        guard let context = CGContext(data: nil, width: Int(rect.width), height: Int(rect.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            return nil
        }
        
        context.draw(image, in: rect)
        return context.makeImage()
    }
    
    /// Scale image to the specified width and height.
    public func scaleCGImage(image: CGImage, width: CGFloat, height: CGFloat) -> CGImage? {
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        guard let context = CGContext(data: nil, width: Int(rect.width), height: Int(rect.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue) else {
            return nil
        }
        
        context.draw(image, in: rect)
        return context.makeImage()
    }
    
    /// Save the image date to a file.
    /// - parameter file: file URL  to be saved into
    /// - parameter data: the data to be saved
    /// - parameter utType: a ``UTType`` to identify the image format
    public func saveToFile(file: URL, data: Data, utType: UTType) throws -> URL {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw ImageIOError()
        }
        
        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ImageIOError()
        }
        
        let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
        guard let dest = CGImageDestinationCreateWithURL(file as CFURL,
                                                         utType.identifier as CFString, 1, nil) else {
            throw ImageIOError()
        }
        
        CGImageDestinationAddImage(dest, cgImage, metadata)
        
        if CGImageDestinationFinalize(dest) {
            return file
        }
        
        throw ImageIOError()
    }
    
    /// Save the ``CGImage`` to a specified file, as a ``UTType``.
    /// - parameter file: file URL  to be saved into
    /// - parameter cgImage: the image to be saved
    /// - parameter utType: a ``UTType`` to identify the image format
    public func saveToFile(file: URL, cgImage: CGImage, utType: UTType) throws -> URL {
        guard let dest = CGImageDestinationCreateWithURL(file as CFURL,
                                                         utType.identifier as CFString, 1, nil) else {
            throw ImageIOError("Failed to create image destination")
        }
        
        CGImageDestinationAddImage(dest, cgImage, nil)
        
        if CGImageDestinationFinalize(dest) {
            return file
        }
        
        throw ImageIOError("Failed to finalize")
    }
    
    /// Get the jpeg data from a ``CGImage``.
    /// - parameter cgImage: the image to get data
    public func getJpegData(cgImage: CGImage) throws -> Data {
        guard let mutableData = CFDataCreateMutable(nil, 0),
              let destination = CGImageDestinationCreateWithData(mutableData, UTType.jpeg.identifier as CFString, 1, nil) else {
            throw ImageIOError("Error on getting data")
        }
        
        CGImageDestinationAddImage(destination, cgImage, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            throw ImageIOError("Error on finalize")
        }
        
        return mutableData as Data
    }
    
    /// Get the orientation from EXIF of the ``file``.
    public func getExifOrientation(file: URL) -> CGImagePropertyOrientation {
        let options: [String: Any] = [
            kCGImageSourceShouldCacheImmediately as String: false,
        ]
        
        guard let source = CGImageSourceCreateWithURL(file as CFURL, options as CFDictionary) else {
            return .up
        }
        
        guard let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) else {
            return .up
        }
        
        guard let map = metadata as? Dictionary<String, Any> else {
            return .up
        }
        
        guard let orientation = map["Orientation"] as? UInt32 else {
            return .up
        }
        return .init(rawValue: orientation) ?? .up
    }
}
