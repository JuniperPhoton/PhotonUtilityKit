//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/7/19.
//

import Foundation
import CoreGraphics

#if canImport(AppKit) && canImport(ScreenCaptureKit) && !targetEnvironment(macCatalyst)
import ScreenCaptureKit
import AppKit

/// Get the CGDirectDisplayID of current NSScreen.
public extension NSScreen {
    var displayID: CGDirectDisplayID? {
        return deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID
    }
}

protocol ScreenshotProvider {
    func captureScreenshot() async throws -> CGImage?
}

/// A ScreenshotProvider using ``CGDisplayCreateImage`` API.
public class CGDisplayScreenshotProvider: ScreenshotProvider {
    func captureScreenshot() async throws -> CGImage? {
        if let displayId = NSScreen.main?.displayID {
            print("captureScreenshotByCGDisplay for displayId: \(displayId)")
            // If we can get the display id from the NSScreen with key window, we use CGDisplayCreateImage directly to get the screenshot.
            return CGDisplayCreateImage(displayId)
        }
        
        return nil
    }
}

/// A ScreenshotProvider using ``CGWindowListCreateImage`` API, which is deprecated in macOS 14.0.
@available(macOS, introduced: 10.5, deprecated: 14.0)
public class CGWindowListScreenshotProvider: ScreenshotProvider {
    func captureScreenshot() async throws -> CGImage? {
        let mainDisplay = NSScreen.screens[0]
        
        // Note that main NSScreen is the one with keyboard focused, and NSScreen.screens[0] should be the one as main display in macOS settings.
        if let currentScreen = NSScreen.main {
            let currentScreenRect = currentScreen.frame
            
            let x = currentScreenRect.minX
            let w = currentScreenRect.width
            let h = currentScreenRect.height
            
            let y = -(currentScreenRect.minY - mainDisplay.frame.height) - currentScreenRect.height
            let clipRect = CGRect(x: x, y: y, width: w, height: h)
            
            // The first parameter is screenBounds, which:
            // - If it is `.infinity`, then CGWindowListCreateImage will return the image contains all screens in all displays
            // - It's coordinate is the one with origin at the upper-left; y-value increasing downward
            // - The NSScreen/frame is the one with origin at the bottom-left; y-value increasing upwawrd, so we need to transfer the coordinate
            return CGWindowListCreateImage(clipRect, .optionOnScreenOnly, .zero, .bestResolution)
        } else {
            return nil
        }
    }
}

/// A ScreenshotProvider using ``ScreenCaptureKit`` API, which is introduced in macOS 13.0, 2022.
@available(macOS 13.0, *)
public class SCKitScreenshotProvider: ScreenshotProvider {
    fileprivate struct ScreenshotError: Error {
        // empty
    }
    
    private var scaleFactor: CGFloat { NSScreen.main?.backingScaleFactor ?? 2.0 }
    private let videoSampleBufferQueue = DispatchQueue(label: "com.juniperphoton.VideoSampleBufferQueue")
    private var stream: SCStream? = nil
    
    func captureScreenshot() async throws -> CGImage? {
        return try await withCheckedThrowingContinuation { continuation in
            captureScreenshot() { image in
                if let image = image {
                    continuation.resume(with: .success(image))
                } else {
                    continuation.resume(with: .failure(ScreenshotError()))
                }
            }
        }
    }
    
    func captureScreenshot(onCaptured: @escaping (CGImage?) -> Void) {
        Task {
            do {
                let currentSharableContent = try await SCShareableContent.current
                
                guard let keyDisplayID = NSScreen.main?.displayID else {
                    onCaptured(nil)
                    return
                }
                                
                guard let display = (currentSharableContent.displays.first { display in
                    display.displayID == keyDisplayID
                }) else {
                    onCaptured(nil)
                    return
                }
                
                let filter = SCContentFilter(display: display, excludingWindows: [])
                                
                let streamConfig = SCStreamConfiguration()
                streamConfig.width = Int(CGFloat(display.width) * scaleFactor)
                streamConfig.height = Int(CGFloat(display.height) * scaleFactor)
                
                let delegate = Delegate { image in
                    onCaptured(image)
                    self.stopCapture()
                }
                
                let stream = SCStream(filter: filter, configuration: streamConfig, delegate: delegate)
                
                // Add a stream output to capture screen content.
                try stream.addStreamOutput(delegate, type: .screen, sampleHandlerQueue: videoSampleBufferQueue)
                
                self.stream = stream
                
                try await stream.startCapture()
            } catch {
                print("error on captureScreenshot \(error)")
                onCaptured(nil)
            }
        }
    }
    
    private func stopCapture() {
        print("stop capture")
        self.stream?.stopCapture { error in
            print("on stopCapture \(String(describing: error))")
            self.stream = nil
        }
    }
    
    class Delegate: NSObject, SCStreamDelegate, SCStreamOutput {
        var onCaptured: (CGImage?) -> Void
        
        init(onCaptured: @escaping (CGImage?) -> Void) {
            self.onCaptured = onCaptured
        }
        
        func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
            // Return early if the sample buffer is invalid.
            guard sampleBuffer.isValid else { return }
            
            // Determine which type of data the sample buffer contains.
            switch type {
            case .screen:
                // Retrieve the array of metadata attachments from the sample buffer.
                guard let attachmentsArray = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer,
                                                                                     createIfNecessary: false) as? [[SCStreamFrameInfo: Any]],
                      let attachments = attachmentsArray.first else { return }
                
                guard let statusRawValue = attachments[SCStreamFrameInfo.status] as? Int,
                      let status = SCFrameStatus(rawValue: statusRawValue),
                      status == .complete else { return }
                
                // Get the pixel buffer that contains the image data.
                guard let pixelBuffer = sampleBuffer.imageBuffer else {
                    onCaptured(nil)
                    return
                }
                
                let ciImage = CIImage(cvImageBuffer: pixelBuffer)
                
                let width = Int(ciImage.extent.width)
                let height = Int(ciImage.extent.height)
                
                let cgImage = CIContext().createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))
                onCaptured(cgImage)
            default:
                break
            }
        }
        
        func stream(_ stream: SCStream, didStopWithError error: Error) {
            print("AppWindowStreamOutput didStopWithError: \(error)")
        }
    }
}
#endif
