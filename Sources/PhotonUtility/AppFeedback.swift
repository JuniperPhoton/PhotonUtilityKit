//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/4/12.
//

import Foundation

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

/// Get a ``URL`` to send feedback to, with ``subject`` and ``body``.
public func getFeedbackURL(subject: String, body: String) -> URL? {
    var component = URLComponents(string: "mailto:dengweichao@hotmail.com")
    component?.queryItems = [
        URLQueryItem(name: "subject", value: subject),
        URLQueryItem(name: "body", value: body)
    ]
    return component?.url
}

/// Get the full os version string with os name, like iOS 16.
public func getOSNameVersion() -> String {
    #if os(iOS) && !targetEnvironment(macCatalyst)
    let osVersion = UIDevice.current.systemVersion
    return "iOS \(String(osVersion))"
    #elseif os(macOS)
    let os = ProcessInfo.processInfo.operatingSystemVersion
    let osVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
    return "macOS \(String(osVersion))"
    #elseif os(tvOS)
    let osVersion = UIDevice.current.systemVersion
    return "tvOS \(String(osVersion))"
    #else
    return ""
    #endif
}
