//
//  SwiftUIView.swift
//
//
//  Created by Photon Juniper on 2023/11/10.
//

import Foundation
import SwiftUI

/// A platform independent InterfaceOrientationMask, copied from ``UIInterfaceOrientationMask``.
///
/// When UIKit can be imported, you can use ``uiKitRepresentation`` to get the corresponding ``UIInterfaceOrientationMask``.
public struct InterfaceOrientationMask : OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let portrait = InterfaceOrientationMask(rawValue: 1 << 0)
    public static let landscapeLeft = InterfaceOrientationMask(rawValue: 1 << 1)
    public static let landscapeRight = InterfaceOrientationMask(rawValue: 1 << 2)
    public static let portraitUpsideDown = InterfaceOrientationMask(rawValue: 1 << 3)
    
    public static let landscape: InterfaceOrientationMask = [.landscapeLeft, .landscapeRight]
    public static let all: InterfaceOrientationMask = [.portrait, .landscape, .portraitUpsideDown ]
    public static let allButUpsideDown: InterfaceOrientationMask = [.portrait, .landscape ]
    
#if canImport(UIKit)
    public var uiKitRepresentation: UIInterfaceOrientationMask {
        var result: UIInterfaceOrientationMask = []
        if self.contains(.portrait) {
            result = result.union(.portrait)
        }
        if self.contains(.landscapeLeft) {
            result = result.union(.landscapeLeft)
        }
        if self.contains(.landscapeRight) {
            result = result.union(.landscapeRight)
        }
        if self.contains(.portraitUpsideDown) {
            result = result.union(.portraitUpsideDown)
        }
        return result
    }
#endif
}

/// Allows you to lock the orientation of the device.
///
/// In your app's delegate, implement this method and return the value:
///
/// ```swift
/// func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
///     return AppOrientation.shared.orientationLock.uiKitRepresentation
/// }
/// ```
///
/// In SwiftUi, you can use the ``View/forceRotation`` modifier to set the value.
public class AppOrientationLocker: ObservableObject {
    public static let shared = AppOrientationLocker()
    
    @Published public var orientationLock = InterfaceOrientationMask.all {
        didSet {
#if canImport(UIKit)
            if #available(iOS 16.0, *) {
                UIApplication.shared.connectedScenes.forEach { scene in
                    if let windowScene = scene as? UIWindowScene {
                        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: orientationLock.uiKitRepresentation))
                    }
                }
                UIViewController.attemptRotationToDeviceOrientation()
            } else {
                if orientationLock == .landscape {
                    UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
                } else {
                    UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                }
            }
#endif
        }
    }
    
    private init() {
        // empty
    }
}

public extension View {
    /// Force the device to change its orientation when this view appears and change it back as it disappears.
    @ViewBuilder
    func lockOrientation(
        appear: InterfaceOrientationMask,
        disappear: InterfaceOrientationMask = .all
    ) -> some View {
        self.modifier(AppOrientationModifier(appear: appear, disappear: disappear))
    }
}

private struct AppOrientationModifier: ViewModifier {
    let appear: InterfaceOrientationMask
    let disappear: InterfaceOrientationMask
    
    func body(content: Content) -> some View {
        content.onAppear() {
            AppOrientationLocker.shared.orientationLock = appear
        }.onDisappear {
            AppOrientationLocker.shared.orientationLock = disappear
        }
    }
}
