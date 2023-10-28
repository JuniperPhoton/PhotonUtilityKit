//
//  AppPhotoLibrary.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2023/1/16.
//

import Foundation
import Photos
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#endif

public class PhotoLibraryIO {
    struct AccessError: Error {
        // empty
    }
    
    public static let shared = PhotoLibraryIO()
    
    private init() {
        // private
    }
    
    public func requestForPermission() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        if status == .denied || status == .notDetermined {
            return false
        }
        return true
    }
    
#if os(iOS)
    public func saveImageToAlbum(uiImage: UIImage) async throws -> Bool {
        if !(await requestForPermission()) {
            throw AccessError()
        }
        
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                let _ = PHAssetCreationRequest.creationRequestForAsset(from: uiImage)
            } completionHandler: { success, error in
                continuation.resume(returning: success)
            }
        }
    }
#endif
    
    public func saveMediaFileToAlbum(
        rawURL: URL,
        processedURL: URL? = nil,
        location: CLLocation? = nil,
        deleteOnComplete: Bool
    ) async -> Bool {
        return await withCheckedContinuation { continuation in
            print("saveMediaFileToAlbum, main of rawURL, processedURL: \(String(describing: processedURL))")

            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.location = location
                
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = deleteOnComplete
                creationRequest.addResource(
                    with: .photo,
                    fileURL: rawURL,
                    options: options
                )
                
                if let processedURL = processedURL {
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = deleteOnComplete
                    creationRequest.addResource(
                        with: .alternatePhoto,
                        fileURL: processedURL,
                        options: options
                    )
                }
            } completionHandler: { success, error in
                print("save media result: \(success) error: \(String(describing: error))")
                
                if deleteOnComplete {
                    do {
                        if let processedURL = processedURL {
                            try FileManager.default.removeItem(at: processedURL.absoluteURL)
                        }                            
                        try FileManager.default.removeItem(at: rawURL.absoluteURL)
                    } catch {
                        // ignored
                    }
                }
                
                continuation.resume(returning: success)
            }
        }
    }
    
    public func saveMediaFileToAlbum(
        processedURL: URL,
        rawURL: URL? = nil,
        location: CLLocation? = nil,
        deleteOnComplete: Bool
    ) async -> Bool {
        return await withCheckedContinuation { continuation in
            LibLogger.shared.libDefault.log("saveMediaFileToAlbum, main of processedURL, raw: \(String(describing: rawURL))")
            
            PHPhotoLibrary.shared().performChanges {
                let creationRequest = PHAssetCreationRequest.forAsset()
                creationRequest.location = location
                
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = deleteOnComplete
                creationRequest.addResource(
                    with: .photo,
                    fileURL: processedURL,
                    options: options
                )
                
                if let rawURL = rawURL {
                    let options = PHAssetResourceCreationOptions()
                    options.shouldMoveFile = deleteOnComplete
                    creationRequest.addResource(
                        with: .alternatePhoto,
                        fileURL: rawURL,
                        options: options
                    )
                }
            } completionHandler: { success, error in
                LibLogger.shared.libDefault.log("save media result: \(success) error: \(String(describing: error))")
                
                if deleteOnComplete {
                    do {
                        if let rawURL = rawURL {
                            try FileManager.default.removeItem(at: rawURL.absoluteURL)
                        }
                        try FileManager.default.removeItem(at: processedURL.absoluteURL)
                    } catch {
                        // ignored
                    }
                }
                
                continuation.resume(returning: success)
            }
        }
    }
    
    public func saveMediaFileToAlbum(
        file: URL,
        location: CLLocation? = nil,
        deleteOnComplete: Bool
    ) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                if file.isImage() {
                    let creation = PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: file.absoluteURL)
                    creation?.location = location
                } else {
                    let creation = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: file.absoluteURL)
                    creation?.location = location
                }
            } completionHandler: { success, error in
                LibLogger.shared.libDefault.log("save media result: \(success) error: \(String(describing: error)), deleteOnComplete: \(deleteOnComplete)")
                
                if deleteOnComplete {
                    do {
                        try FileManager.default.removeItem(at: file.absoluteURL)
                    } catch {
                        print("error on delete \(file.absoluteURL), \(error)")
                    }
                }
                
                continuation.resume(returning: success)
            }
        }
    }
    
    public func delete(asset: PHAsset) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                let _ = PHAssetChangeRequest.deleteAssets([asset] as NSArray)
            } completionHandler: { success, error in
                continuation.resume(returning: success)
            }
        }
    }
    
    public func favorite(asset: PHAsset) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest(for: asset)
                request.isFavorite = true
            } completionHandler: { success, error in
                continuation.resume(returning: success)
            }
        }
    }
    
    public func createTempFileToSave(originalFilename: String, utType: UTType) -> URL? {
        guard let extensions = utType.preferredFilenameExtension else {
            print("error on getting preferredFilenameExtension")
            return nil
        }
        return createTempFileToSave(originalFilename: originalFilename, extensions: extensions)
    }
    
    public func createTempFileToSave(
        originalFilename: String,
        subDirName: String? = nil,
        extensions: String
    ) -> URL? {
        guard var cacheDir = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            print("error on create cache url for file")
            return nil
        }
        
        if let subDirName = subDirName,
           let dir = URL(string: "\(cacheDir.absoluteString)\(subDirName)/") {
            do {
                try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                cacheDir = dir
            } catch {
                return nil
            }
        }
        
        guard let name = NSString(string: originalFilename).deletingPathExtension
            .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
            print("createTempFileToSave failed for name \(originalFilename)")
            return nil
        }
        
        let fileName = name  + "." + extensions
        
        let url = URL(string: "\(cacheDir.absoluteString)\(fileName)")
                
        if let url = url, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        
        return url
    }
}
