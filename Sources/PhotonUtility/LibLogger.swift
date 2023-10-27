//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/10/27.
//

import Foundation
import OSLog

class LibLogger {
    static let shared = LibLogger()
    
    var libDefault = Logger(subsystem: "com.juniperphoton.photonutility", category: "libDefault")
}
