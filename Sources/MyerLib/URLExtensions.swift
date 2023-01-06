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
    
    func isImage() -> Bool {
        guard let typeID = try? self.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else {
            return false
        }
        
        let utType = UTType(typeID)
        
        if let supertypes = utType?.supertypes {
            if supertypes.contains(.image) {
                return true
            }
        }
        
        // We check the UTType of the content to avoid loading data for non-image file
        if utType != .tiff
            && utType != .jpeg
            && utType != .png
            && utType != .heic
            && utType != .rawImage
            && utType?.identifier != "com.adobe.raw-image" {
            return false
        }
        
        return true
    }
}
