//
//  URL+Extensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/22.
//

import Foundation

public extension URL {
    var isDir: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
}
