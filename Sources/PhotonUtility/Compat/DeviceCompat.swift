//
//  DeviceCompat.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/13.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

private let duoIdentifier = "iPhone19,4"

public class DeviceCompat {
    private init() {
        // private
    }
    
    /// Check if it's running as an iOS/iPadOS app on Mac.
    public static var isiOSAppOnMac: Bool = {
        ProcessInfo.processInfo.isiOSAppOnMac
    }()
    
    /// Check if it's running natively on a Mac.
    ///
    /// > Note: To check if it's running on Mac using Catalyst technology, using ``isMacCatalyst()`` instead.
    public static func isMac() -> Bool {
#if os(iOS)
        return false
#elseif os(macOS)
        return true
#else
        return false
#endif
    }
    
    /// Check if it's running on a Mac using Catalyst technology.
    public static func isMacCatalyst() -> Bool {
#if targetEnvironment(macCatalyst)
        return true
#else
        return false
#endif
    }
    
    /// Check if it's running on a Apple TV.
    public static func isTV() -> Bool {
#if os(tvOS)
        return true
#else
        return false
#endif
    }
    
    /// Check if it's running on a iPhone.
    public static func isOnPhoneOnly() -> Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
#else
        return false
#endif
    }
    
    /// Check if it's running on a iPad.
    public static func isiPad() -> Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
#else
        return false
#endif
    }
    
    /// Check if it's running on a iOS device, including iPhone and iPad.
    public static func isiOS() -> Bool {
#if os(iOS)
        return true
#else
        return false
#endif
    }
    
#if os(iOS)
    private static let impact = UIImpactFeedbackGenerator(style: .light)
#endif
    
    public static func triggerVibrationFeedback() {
#if os(iOS)
        impact.impactOccurred()
#endif
    }
    
    /// Check if current os version is released in 2022.
    public static func isOS2022AndAbove() -> Bool {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return true
        }
        return false
    }
    
    public static var isFoldableDevice: Bool = {
        return modelIdentifier == duoIdentifier
    }()
    
    public static var modelIdentifier: String = {
#if targetEnvironment(simulator)
        return duoIdentifier
#else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
#endif
    }()
}
