//
//  URL+Extensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/22.
//

import Foundation
import UniformTypeIdentifiers

public extension URL {
    /// Check if t his URL represents a dir.
    var isDir: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    /// Get the file extension from this URL. Return empty if not found.
    func getExtension() -> String {
        return NSString(string: self.absoluteString).pathExtension
    }
    
    /// Get the file name with extension.
    func getNameWithoutExtension() -> String {
        let string = NSString(string: self.absoluteString).deletingPathExtension
        guard let url = URL(string: string) else {
            return ""
        }
        return url.lastPathComponent
    }
    
    /// Replace the extension to the URL.
    /// - parameter extensions: extension to replace. Do not starting with `.`.
    func replaceExtension(extensions: String) -> String {
        let path = getNameWithoutExtension()
        if path.isEmpty {
            return ""
        }
        return "\(path).\(extensions)"
    }
    
    /// Get the ``UTType`` from this URL.
    func getUTType() -> UTType? {
        guard let typeID = try? self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return nil
        }
        
        return UTType(typeID)
    }
    
    /// Check if this URL represents an image type.
    func isImage() -> Bool {
        guard let utType = getUTType() else {
            return false
        }
        
        return utType.isImage()
    }
    
    /// Check if this URL represents a RAW image type.
    func isRawImage() -> Bool {
        guard let utType = getUTType() else {
            return false
        }
        
        return utType.isRawImage()
    }
}

public extension URL {
    /// Grant permission to access the URL.
    func grantAccess<T>(access: (URL) -> T) -> T {
        let granted = self.startAccessingSecurityScopedResource()
        
        defer {
            if granted {
                self.stopAccessingSecurityScopedResource()
            }
        }
        
        return access(self)
    }
    
    /// Grant permission to access the URL, allowing you to perform async action in the block and return the result.
    func grantAccessAsync<T>(access: (URL) async -> T) async -> T {
        let granted = self.startAccessingSecurityScopedResource()
        
        defer {
            if granted {
                self.stopAccessingSecurityScopedResource()
            }
        }
        
        return await access(self)
    }
}
