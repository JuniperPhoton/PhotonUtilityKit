//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/10/27.
//

import Foundation
import CoreMotion
import Combine
import AVFoundation

#if canImport(UIKit)
import UIKit
#endif

public enum DeviceOrientation: Int {
    case unknown = 0
    case portrait = 1 // Device oriented vertically, home button on the bottom
    case portraitUpsideDown = 2 // Device oriented vertically, home button on the top
    case landscapeLeft = 3 // Device oriented horizontally, home button on the right
    case landscapeRight = 4 // Device oriented horizontally, home button on the left
    case faceUp = 5 // Device oriented flat, face up
    case faceDown = 6 // Device oriented flat, face down
    
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
    
#if canImport(UIKit)
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

public class DeviceOrientationInfo: ObservableObject {
    public static let shared = DeviceOrientationInfo()
    
    private var motionManager: CMMotionManager? = nil
    
    @Published public var orientation = DeviceOrientation.portrait
    
    private init() {
        // empty
    }
    
    public func start() {
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
                
                if self.orientation != orientation {
                    self.orientation = orientation
                }
            }
        }
        
        self.motionManager = motionManager
    }
    
    public func stop() {
        LibLogger.shared.libDefault.log("stop detecting orientation")
        motionManager?.stopAccelerometerUpdates()
        motionManager = nil
    }
}
