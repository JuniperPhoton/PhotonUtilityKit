//
//  File.swift
//
//
//  Created by Photon Juniper on 2024/4/15.
//

import Foundation

/// Provides some easing functions from https://easings.net.
public class EasingFunctions {
    static public func easeInOutQuint(_ x: CGFloat) -> CGFloat {
        return x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2
    }
    
    static public func easeOutQuint(_ x: CGFloat) -> CGFloat {
        return 1 - pow(1 - x, 5)
    }
    
    static public func easeInQuint(_ x: CGFloat) -> CGFloat {
        return x * x * x * x * x
    }
    
    static public func easeInSine(_ x: CGFloat) -> CGFloat {
        return 1 - cos((x * .pi) / 2)
    }
    
    static public func easeOutSine(_ x: CGFloat) -> CGFloat {
        return sin((x * .pi) / 2)
    }
    
    static public func easeInOutSine(_ x: CGFloat) -> CGFloat {
        return -(cos(.pi * x) - 1) / 2
    }
    
    static public func easeInCubic(_ x: CGFloat) -> CGFloat {
        return x * x * x
    }
    
    static public func easeOutCubic(_ x: CGFloat) -> CGFloat {
        return 1 - pow(1 - x, 3)
    }
    
    static public func easeInOutCubic(_ x: CGFloat) -> CGFloat {
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }
    
    static public func easeInCirc(_ x: CGFloat) -> CGFloat {
        return 1 - sqrt(1 - pow(x, 2))
    }
    
    static public func easeOutCirc(_ x: CGFloat) -> CGFloat {
        return sqrt(1 - pow(x - 1, 2))
    }
    
    static public func easeInOutCirc(_ x: CGFloat) -> CGFloat {
        return x < 0.5 ? (1 - sqrt(1 - pow(2 * x, 2))) / 2 : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2
    }
}
