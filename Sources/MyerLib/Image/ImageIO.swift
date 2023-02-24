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
}
