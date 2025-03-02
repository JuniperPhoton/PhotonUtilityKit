//
//  URL+FileSize.swift
//  PhotonCam
//
//  Created by Photon Juniper on 2024/6/8.
//

import Foundation

public extension URL {
    var fileSize: Int? {
        do {
            let value = try self.resourceValues(forKeys: [.fileSizeKey])
            return value.fileSize
        } catch {
            return 0
        }
    }
}
