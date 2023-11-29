//
//  File.swift
//
//
//  Created by Photon Juniper on 2023/10/27.
//

import Foundation
import Combine
import AVFoundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(CoreMotion)
import CoreMotion
#endif

/// The device orientation used in ``DeviceOrientationInfo``.
public enum DeviceOrientation: Int {
    case unknown = 0
    case portrait = 1 // Device oriented vertically, home button on the bottom
    case portraitUpsideDown = 2 // Device oriented vertically, home button on the top
    case landscapeLeft = 3 // Device oriented horizontally, home button on the right
    case landscapeRight = 4 // Device oriented horizontally, home button on the left
    case faceUp = 5 // Device oriented flat, face up
    case faceDown = 6 // Device oriented flat, face down
    
#if !os(tvOS)
    public func toAVCaptureVideoOrientation() -> AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .portrait
        }
    }
#endif
    
#if os(iOS)
    public func toUIDeviceOrientation() -> UIDeviceOrientation {
        switch self {
        case .unknown:
            return .unknown
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        case .faceUp:
            return .faceUp
        case .faceDown:
            return .faceDown
        }
    }
#endif
    
    public var orientationAngleInDegrees: Double {
        switch self {
        case .portraitUpsideDown:
            180
        case .landscapeLeft:
            90
        case .landscapeRight:
            -90
        default:
            0
        }
    }
}

/// Observe and publish device orientation info.
///
/// This orientation info is independent to the device lock which may be turned on by users.
/// The orientation will be useful when detecting orientation while building a camera app.
///
/// You don't create the instance of this. Instead, please use ``shared`` to get a singleton of it.
///
/// Note that the observation only supports iOS. For macOS and tvOS, the ``orientation``
/// will always be ``DeviceOrientation.portrait`` and the ``start`` or ``stop`` methods
/// won't do anyting.
public class DeviceOrientationInfo: ObservableObject {
    /// Get the shared instance of ``DeviceOrientationInfo``.
    public static let shared = DeviceOrientationInfo()
    
#if os(iOS)
    private var motionManager: CMMotionManager? = nil
#endif
    
    /// Get or observe the lastest orientation.
    @Published public var orientation = DeviceOrientation.portrait
    
    /// Get or observe the underlying ``CMAcceleration``.
    @Published public var acceleration: CMAcceleration? = nil
    
    private init() {
        // empty
    }
    
    /// Start the detection. Please remember to ``stop`` when inactive.
    public func start() {
#if os(iOS)
        LibLogger.shared.libDefault.log("start detecting orientation")
        
        stop()
        
        let motionManager = CMMotionManager()
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 24.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data, let self = self else {
                    return
                }
                
                var orientation: DeviceOrientation = self.orientation
                if data.acceleration.x >= 0.75 {
                    orientation = .landscapeRight
                } else if data.acceleration.x <= -0.75 {
                    orientation = .landscapeLeft
                } else if data.acceleration.y <= -0.75 {
                    orientation = .portrait
                } else if data.acceleration.y >= 0.75 {
                    orientation = .portraitUpsideDown
                }
                
                if self.acceleration != data.acceleration {
                    self.acceleration = data.acceleration
                }
                
                if self.orientation != orientation {
                    self.orientation = orientation
                }
            }
        }
        
        self.motionManager = motionManager
#endif
    }
    
    /// Stop the detection.
    public func stop() {
#if os(iOS)
        LibLogger.shared.libDefault.log("stop detecting orientation")
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
#endif
    }
}

extension CMAcceleration: Equatable {
    public static func == (lhs: CMAcceleration, rhs: CMAcceleration) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
