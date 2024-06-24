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
public class DeviceOrientationSimpleInfo: ObservableObject {
    /// Get or observe the latest orientation.
    @Published public fileprivate(set) var orientation = DeviceOrientation.portrait
}

/// Observe and publish device orientation info and orientation data.
///
/// The ``data`` will be updated frequently; therefore, if you are only concerned with the orientation (left, right, etc.),
/// you should observe the ``DeviceOrientationSimpleInfo``.
///
/// This orientation info is independent to the device lock which may be turned on by users.
/// The orientation will be useful when detecting orientation while building a camera app.
///
/// You don't create the instance of this. Instead, please use ``shared`` to get a singleton of it.
///
/// Note that the observation only supports iOS. For macOS and tvOS, the ``orientation``
/// will always be ``DeviceOrientation.portrait`` and the ``start`` or ``stop`` methods
/// won't do anything.
public class DeviceOrientationInfo: ObservableObject {
    /// Get the shared instance of ``DeviceOrientationInfo``.
    public static let shared = DeviceOrientationInfo()
    
#if os(iOS)
    private var motionManager: CMMotionManager? = nil
#endif
    
#if os(iOS)
    /// Get or observe the underlying ``CMDeviceMotion``.
    @Published public private(set) var data: CMDeviceMotion? = nil
#endif
    
    public var orientation: DeviceOrientation {
        simpleInfo.orientation
    }
    
    public let simpleInfo = DeviceOrientationSimpleInfo()

    private init() {
        // empty
    }
    
    /// Start the detection. Please remember to ``stop`` when inactive.
    public func start() {
#if os(iOS)
        LibLogger.shared.libDefault.log("start detecting orientation")
        
        stop()
        
        let motionManager = CMMotionManager()
        
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(
                using: .xArbitraryZVertical,
                to: .main
            ) { [weak self] data, error in
                guard let data = data, let self = self else {
                    return
                }
                                                
                if self.data != data {
                    self.data = data
                }
            }
        }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let data = data, let self = self else {
                    return
                }
                
                var orientation: DeviceOrientation = self.simpleInfo.orientation
                if data.acceleration.x >= 0.75 {
                    orientation = .landscapeRight
                } else if data.acceleration.x <= -0.75 {
                    orientation = .landscapeLeft
                } else if data.acceleration.y <= -0.75 {
                    orientation = .portrait
                } else if data.acceleration.y >= 0.75 {
                    orientation = .portraitUpsideDown
                }
                
                if self.simpleInfo.orientation != orientation {
                    self.simpleInfo.orientation = orientation
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
        motionManager?.stopDeviceMotionUpdates()
        motionManager = nil
#endif
    }
}

#if os(iOS)
extension CMRotationRate: Equatable {
    public static func == (lhs: CMRotationRate, rhs: CMRotationRate) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}

extension CMAcceleration: Equatable {
    public static func == (lhs: CMAcceleration, rhs: CMAcceleration) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
}
#endif
