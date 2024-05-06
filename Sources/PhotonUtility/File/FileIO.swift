//
//  File.swift
//
//
//  Created by Photon Juniper on 2023/2/24.
//

import Foundation

public class FileIO {
    public static let shared = FileIO()
    
    public struct IOError: Error {
        // empty
    }
    
    private init() {
        // empty
    }
    
    /// Get file size in bytes.
    public func getFileSize(file: URL) -> Int64 {
        return (try? (FileManager.default.attributesOfItem(atPath: file.path)[.size] as? Int64)) ?? 0
    }
    
    /// Copy the file of ``srcURL`` to ``destURL`` by stream.
    ///
    /// Before calling this method, make sure you have access permission to it.
    ///
    /// When in the SandBox environment, you must call URL's startAccessingSecurityScopedResource to get permission.
    public func copyByStream(srcURL: URL, destURL: URL) throws {
        guard let stream = InputStream(url: srcURL),
              let outputStream = OutputStream(url: destURL, append: false) else {
            return
        }
        
        stream.open()
        outputStream.open()
        
        defer {
            stream.close()
            outputStream.close()
        }
        
        var buffer = [UInt8](repeating: 0, count: 4096)
        while stream.hasBytesAvailable {
            let numberOfBytesRead = stream.read(&buffer, maxLength: buffer.count)
            if numberOfBytesRead < 0, stream.streamError != nil {
                throw IOError()
            } else if numberOfBytesRead > 0 {
                outputStream.write(buffer, maxLength: numberOfBytesRead)
            }
        }
    }
}
