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

public class DeviceCompat {
    private init() {
        // private
    }
    
    public static func isOnPhoneOnly() -> Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
#else
        return false
#endif
    }
    
    public static func isiPad() -> Bool {
#if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
#else
        return false
#endif
    }
    
    public static func isiOS() -> Bool {
#if os(iOS)
        return true
#else
        return false
#endif
    }
}
