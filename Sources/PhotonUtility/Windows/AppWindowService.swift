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

#if canImport(ScreenCaptureKit)
import ScreenCaptureKit
#endif

/// Provides some utility methods for window service, like creating a screenshot.
public class AppWindowService {
    public static let shared = AppWindowService()
    
    private init() {
        // empty
    }
    
    /// Checks whether the current process already has screen capture access
    public func isScreenCaptureAccessEnabled() -> Bool {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        return CGPreflightScreenCaptureAccess()
#else
        return false
#endif
    }
    
    /// Requests event listening access if absent, potentially prompting
    @discardableResult
    public func requestScreenCaptureAccess() -> Bool {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
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
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        guard let cgImage = await createScreenshot(bestResolution: false) else {
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
    
    /// Create original screenshot.
    /// - parameter bestResolution: true to return the best resolution, which should be the same pixel size of the screen.
    public func createScreenshot(bestResolution: Bool) async -> CGImage? {
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
        var providers: [any ScreenshotProvider] = []
        
        if #available(macOS 13.0, *) {
            providers = [CGDisplayScreenshotProvider(), SCKitScreenshotProvider()]
        } else {
            providers = [CGDisplayScreenshotProvider(), CGWindowListScreenshotProvider()]
        }
        
        var providerIndex = 0
        var resultImage: CGImage? = nil
        
        repeat {
            resultImage = try? await providers[providerIndex].captureScreenshot()
            providerIndex += 1
        } while(resultImage == nil && providerIndex < providers.count)
        
        return resultImage
#else
        return nil
#endif
    }
}
