//
//  File.swift
//
//
//  Created by Photon Juniper on 2024/4/15.
//

import Foundation

/// Provides some easing functions from https://easings.net.
public class EasingFunctions {
    /// https://easings.net/#easeInOutQuint
    static public func easeInOutQuint(_ x: CGFloat) -> CGFloat {
        return x < 0.5 ? 16 * x * x * x * x * x : 1 - Math.pow(-2 * x + 2, 5) / 2;
    }
    
    /// https://easings.net/#easeOutQuint
    static func easeOutQuint(_ x: CGFloat) -> CGFloat {
        return 1 - pow(1 - x, 5);
    }
    
    /// https://easings.net/#easeInQuint
    static func easeInQuint(_ x: CGFloat) -> CGFloat {
        return x * x * x * x * x;
    }
}
