//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/5/5.
//

import Foundation

#if canImport(AppKit)
import ServiceManagement

/// Provide a compat way to implement auto-login feature.
/// For macOS 13.0+, it uses the new ``SMAppService`` API to add the app to login items list.
/// For the prior version of macOS 13.0, it fallbacks to use ``SMLoginItemSetEnabled``,
/// which requires you setup a auto-login helper target with a specified ``launcherHelperIdentifier``
/// you pass in the constructor.
///
/// For more details:
/// https://jogendra.dev/implementing-launch-at-login-feature-in-macos-apps
/// https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLoginItems.html#//apple_ref/doc/uid/10000172i-SW5-BAJJBJEG
public class LoginItemCompat {
    private let useNewAPI: Bool = true
    private let launcherHelperIdentifier: String
    
    public init(launcherHelperIdentifier: String) {
        self.launcherHelperIdentifier = launcherHelperIdentifier
    }
    
    public func register() {
        if #available(macOS 13.0, *), useNewAPI {
            registerInternalForVentura()
        } else {
            SMLoginItemSetEnabled(launcherHelperIdentifier as CFString, true)
        }
    }
    
    public func unregister() {
        if #available(macOS 13.0, *), useNewAPI {
            unregisterInternalForVentura()
        } else {
            SMLoginItemSetEnabled(launcherHelperIdentifier as CFString, false)
        }
    }
    
    @available(macOS 13.0, *)
    private func registerInternalForVentura() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            print("error on register SMAppService \(error)")
        }
    }
    
    @available(macOS 13.0, *)
    private func unregisterInternalForVentura() {
        do {
            try SMAppService.mainApp.unregister()
        } catch {
            print("error on unregister SMAppService \(error)")
        }
    }
}
#endif
