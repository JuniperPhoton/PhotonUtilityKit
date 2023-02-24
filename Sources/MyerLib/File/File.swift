//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/2/24.
//

import Foundation

public class FileIO {
    public static let shared = FileIO()
    
    private init() {
        // empty
    }
    
    /// Get file size in bytes.
    public func getFileSize(file: URL) -> Int64 {
        return (try? (FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int64)) ?? 0
    }
}
