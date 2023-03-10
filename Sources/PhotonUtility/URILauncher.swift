//
//  File.swift
//  
//
//  Created by Photon Juniper on 2022/12/7.
//

import Foundation
#if os(macOS)
import AppKit

@available(*, deprecated, message: "Use the system environment value openURL instead.")
public class URILauncher {
    public static let shared = URILauncher()
    
    public func openURI(url: URL) {
        NSWorkspace.shared.open(url)
    }
    
    private init() {
        // private constructor
    }
}

#elseif os(iOS)
import UIKit

@available(*, deprecated, message: "Use the system environment value openURL instead.")
public class URILauncher {
    public static let shared = URILauncher()
    
    public func openURI(url: URL) {
        UIApplication.shared.open(url, completionHandler: nil)
    }
    
    private init() {
        // private constructor
    }
}
#endif
