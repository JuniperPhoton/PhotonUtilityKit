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
    
    public func saveMediaFileToAlbum(file: URL, deleteOnComplete: Bool) async -> Bool {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.shared().performChanges {
                if file.isImage() {
                    print("creationRequestForAssetFromImage for url \(file.absoluteURL)")
                    let _ = PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: file.absoluteURL)
                } else {
                    print("creationRequestForAssetFromVideo for url \(file.absoluteURL)")
                    let _ = PHAssetCreationRequest.creationRequestForAssetFromVideo(atFileURL: file.absoluteURL)
                }
            } completionHandler: { success, error in
                print("save media result: \(success) error: \(String(describing: error)), deleteOnComplete: \(deleteOnComplete)")
                
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
    
    public func createTempFileToSave(originalFilename: String, extensions: String) -> URL? {
        guard let cacheDir = try? FileManager.default.url(for: .documentDirectory,
                                                          in: .userDomainMask,
                                                          appropriateFor: nil,
                                                          create: true) else {
            print("error on create cache url for file")
            return nil
        }
                
        guard let name = NSString(string: originalFilename).deletingPathExtension
            .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) else {
            print("createTempFileToSave failed for name \(originalFilename)")
            return nil
        }
        
        let fileName = name  + "." + extensions
        
        let url = URL(string: "\(cacheDir.absoluteString)\(fileName)")
        print("createTempFileToSave in \(cacheDir), for name \(fileName), output: \(url != nil)")
        
        if let url = url, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(at: url)
        }
        
        return url
    }
}
