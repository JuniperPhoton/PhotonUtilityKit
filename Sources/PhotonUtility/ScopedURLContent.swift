//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/8/10.
//

import Foundation

/// Represents a selected ``parent`` URL with its content ``files``.
/// To access the ``files``, you must access them within``tryAccess(block:)``.
///
/// Note that the ``startAccessingSecurityScopedResource`` method should be invoked by the root folder the user selected, not the contents of dir.
public struct ScopedURLContent: CustomStringConvertible {
    public let parent: URL?
    public let files: [URL]
    
    public var description: String {
        return "parent \(String(describing: parent)), files count \(files.count)"
    }
    
    public var isEmpty: Bool {
        return files.isEmpty
    }
    
    public var count: Int {
        return files.count
    }
    
    public init(parent: URL?, files: [URL]) {
        self.parent = parent
        self.files = files
    }
    
    public func tryAccess<T>(block: () -> T) -> T {
        let access = parent?.startAccessingSecurityScopedResource() ?? false
        
        defer {
            if access {
                parent?.stopAccessingSecurityScopedResource()
            }
        }
        
        return block()
    }
    
    public func tryAccess<T>(block: () async -> T) async -> T {
        let access = parent?.startAccessingSecurityScopedResource() ?? false
        
        defer {
            if access {
                parent?.stopAccessingSecurityScopedResource()
            }
        }
        
        return await block()
    }
}
