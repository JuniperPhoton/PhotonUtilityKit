//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/1/16.
//

import Foundation
import UniformTypeIdentifiers

public extension UTType {
    func isImage() -> Bool {
        let imageSuperTypes = [UTType.rawImage, UTType.image]
        let imageTypes = [
            UTType.tiff,
            UTType.png,
            UTType.jpeg,
            UTType.heic,
            UTType.heif,
            UTType.rawImage
        ]
        return isTypeFor(superTypes: imageSuperTypes, orSubTypes: imageTypes)
    }
    
    func isRawImage() -> Bool {
        return isTypeFor(superTypes: [UTType.rawImage], orSubTypes: [UTType.rawImage])
    }
    
    func isTypeFor(superTypes: [UTType], orSubTypes: [UTType]) -> Bool {
        let superType = superTypes.first { type in
            self.isSubtype(of: type)
        }
        
        if superType != nil {
            return true
        }
        
        return orSubTypes.contains(self)
    }
}
