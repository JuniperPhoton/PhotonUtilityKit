//
//  URL+Extensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/22.
//

import Foundation
import UniformTypeIdentifiers

public extension URL {
    var isDir: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    
    func getExtension() -> String {
        return NSString(string: self.absoluteString).pathExtension
    }
    
    func getNameWithoutExtension() -> String {
        let string = NSString(string: self.absoluteString).deletingPathExtension
        guard let url = URL(string: string) else {
            return ""
        }
        return url.lastPathComponent
    }
    
    func replaceExtension(extensions: String) -> String {
        let path = getNameWithoutExtension()
        if path.isEmpty {
            return ""
        }
        return "\(path).\(extensions)"
    }
    
    func getUTType() -> UTType? {
        guard let typeID = try? self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return nil
        }
        
        return UTType(typeID)
    }
    
    func isImage() -> Bool {
        guard let typeID = try? self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return false
        }
        
        guard let utType = UTType(typeID) else {
            return false
        }
        
        return utType.isImage()
    }
    
    func isRawImage() -> Bool {
        guard let typeID = try? self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return false
        }
        
        guard let utType = UTType(typeID) else {
            return false
        }
        
        return utType.isRawImage()
    }
}
