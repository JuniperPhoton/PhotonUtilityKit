//
//  AppLockScreenTimer.swift
//  MyerSplash.Apple
//
//  Created by Photon Juniper on 2023/2/6.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class AppLockScreenTimer {
    /// Disable lock screen automatically for iOS and iPadOS.
    public static func keepScreenOn(_ on: Bool) {
#if os(iOS)
        UIApplication.shared.isIdleTimerDisabled = on
#endif
    }
}
