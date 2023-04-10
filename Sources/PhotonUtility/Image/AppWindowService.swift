//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/3/23.
//

import Foundation
import CoreGraphics

#if canImport(AppKit)
import AppKit
#endif

/// Provides some utility methods for window service, like creating a screenshot.
public class AppWindowService {
    public static let shared = AppWindowService()
    
    private init() {
        // empty
    }
    
    /// Checks whether the current process already has screen capture access
    public func isScreenCaptureAccessEnabled() -> Bool {
#if canImport(AppKit)
        return CGPreflightScreenCaptureAccess()
#else
        return false
#endif
    }
    
    /// Requests event listening access if absent, potentially prompting
    @discardableResult
    public func requestScreenCaptureAccess() -> Bool {
#if canImport(AppKit)
        return CGRequestScreenCaptureAccess()
#else
        return false
#endif
    }
    
    /// Take a Screenshot for the current screen and return the ``CGImage`` if it's available.
    /// Available for macOS only, if you call it in iOS, it simply returns nil.
    /// - parameter croppedTo: a ``CGRect`` representing the cropped area
    @MainActor
    public func createScreenshot(croppedTo: CGRect?) async -> CGImage? {
#if canImport(AppKit)
        guard let cgImage = createScreenshot(bestResolution: false) else {
            return nil
        }
                
        var resultImage: CGImage? = cgImage
        
        if let croppedTo = croppedTo {
            var croppedToFrame = croppedTo
            if croppedToFrame.isEmpty {
                return nil
            }
            
            guard let currentWindow = NSApplication.shared.currentEvent?.window else {
                return nil
            }
                        
            croppedToFrame = croppedToFrame.offsetBy(dx: currentWindow.frame.minX,
                                                     dy: -currentWindow.frame.minY)
            
            resultImage = cgImage.cropping(to: croppedToFrame)
        }
        
        return resultImage
#else
        return nil
#endif
    }
    
    /// Crop the original image to a specified ``CGRect``.
    /// The original image should be the scaled size of the screen, not the original.
    @MainActor
    public func cropScreenshotSafeAreaAware(originalImage: CGImage,
                                            croppedTo: CGRect) -> CGImage? {
        #if os(macOS)
        guard let currentWindow = NSApplication.shared.currentEvent?.window else {
            print("current event is nil")
            return nil
        }
        
        var croppedToFrame = croppedTo
        croppedToFrame = croppedToFrame.offsetBy(dx: currentWindow.frame.minX,
                                                 dy: -currentWindow.frame.minY)
        
        return originalImage.cropping(to: croppedToFrame)
        #else
        return nil
        #endif
    }
    
    /// Create original screenshot.
    /// - parameter bestResolution: true to return the best resolution, which should be the same pixel size of the screen.
    public func createScreenshot(bestResolution: Bool) -> CGImage? {
#if canImport(AppKit)
        return CGWindowListCreateImage(.infinite, .optionOnScreenOnly,
                                       .zero,
                                       bestResolution ? .bestResolution : .nominalResolution)
#else
        return nil
#endif
    }
}
