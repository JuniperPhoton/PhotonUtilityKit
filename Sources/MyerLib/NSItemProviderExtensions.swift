//
//  NSItemProviderExtensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/24.
//

import Foundation

extension NSItemProvider {
    func loadUrl(identifiers: [String] = ["public.url", "public.file-url", "public.folder"]) async -> URL? {
        return await withCheckedContinuation { continuation in
            guard let identifier = self.registeredTypeIdentifiers.first else {
                continuation.resume(returning: nil)
                return
            }
            
            if identifiers.contains(identifier) == true {
                self.loadUrl { url in
                    AppLogger.defaultLogger.info("performDrop load url: \(String(describing: url))")
                    continuation.resume(returning: url)
                }
            } else {
                AppLogger.defaultLogger.error("identifier is unknown: \(identifier)")
                continuation.resume(returning: nil)
            }
        }
    }
}
