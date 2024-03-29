//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/2/14.
//

import Foundation
import CoreGraphics
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public extension NSItemProvider {
    func loadAsCGImage() async -> CGImage? {
#if os(iOS)
        return await loadAsUIImage()?.cgImage
#elseif os(macOS)
        return await loadAsNSImage()?.cgImage(forProposedRect: nil, context: nil, hints: nil)
#else
        return nil
#endif
    }
    
#if os(iOS)
    func loadAsUIImage() async -> UIImage? {
        return await withCheckedContinuation { continuation in
            if !self.canLoadObject(ofClass: UIImage.self) {
                continuation.resume(returning: nil)
                return
            }
            
            self.loadObject(ofClass: UIImage.self) { uiImage, error in
                continuation.resume(returning: uiImage as? UIImage)
            }
        }
    }
#endif
    
#if os(macOS)
    func loadAsNSImage() async -> NSImage? {
        return await withCheckedContinuation { continuation in
            if #available(macOS 13.0, *) {
                if !self.canLoadObject(ofClass: NSImage.self) {
                    continuation.resume(returning: nil)
                    return
                }
                self.loadObject(ofClass: NSImage.self) { nsImage, error in
                    continuation.resume(returning: nsImage as? NSImage)
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
#endif
}

public extension NSItemProvider {
    func loadAsUrl() async -> URL? {
        var url = await tryLoadAsFileRepresentation()
        if url == nil {
            url = await tryLoadAsPasteboardType()
        }
        return url
    }
    
    private func tryLoadAsFileRepresentation() async -> URL? {
        return await withCheckedContinuation { continuation in
            _ = self.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.folder.identifier, completionHandler: { url, success, error in
                continuation.resume(returning: url)
            })
        }
    }
    
    private func tryLoadAsPasteboardType() async -> URL? {
#if os(macOS)
        return await withCheckedContinuation { continuation in
            _ = self.loadObject(ofClass: NSPasteboard.PasteboardType.self) { pasteboardItem, _ in
                guard let rawValue = pasteboardItem?.rawValue else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: URL(string: rawValue)!)
            }
        }
#else
        return nil
#endif
    }
}
