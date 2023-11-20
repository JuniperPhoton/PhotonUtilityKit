//
//  SwiftUIView.swift
//
//
//  Created by Photon Juniper on 2023/8/10.
//

import SwiftUI
import CoreGraphics

public extension Color {
    /// Create ``Color`` from a hex string.
    ///
    /// The format of the string should be:
    /// - Starts with '#'
    /// - Has 6 numbers(rgb) or 8 numbers(argb), like #AARRGGBB or #RRGGBB
    init?(hexString: String?) {
        if let cgColor = CGColor.create(hexString: hexString) {
#if canImport(AppKit)
            if let color = Color.createFromCGColor(cgColor: cgColor) {
                self = color
            } else {
                return nil
            }
#else
            self = Color(cgColor: cgColor)
#endif
        } else {
            return nil
        }
    }
    
    init?(hex: UInt, alpha: Double = 1) {
        if let cgColor = CGColor.create(hex: hex, alpha: alpha) {
            if let color = Color.createFromCGColor(cgColor: cgColor) {
                self = color
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    static func createFromCGColor(cgColor: CGColor) -> Color? {
        if let components = cgColor.components {
#if canImport(AppKit)
            let a: Double
            let r: Double
            let g: Double
            let b: Double
            if components.count == 3 {
                a = 1.0
                r = components[0]
                g = components[1]
                b = components[2]
            } else if components.count == 4 {
                r = components[0]
                g = components[1]
                b = components[2]
                a = components[3]
            } else {
                return nil
            }
            return Color(red: r, green: g, blue: b, opacity: a)
#else
            return Color(cgColor: cgColor)
#endif
        } else {
            return nil
        }
    }
}

public extension CGColor {
    static func create(hex: UInt, alpha: Double = 1) -> CGColor? {
        let r = Double((hex >> 16) & 0xff) / 255
        let g = Double((hex >> 08) & 0xff) / 255
        let b = Double((hex >> 00) & 0xff) / 255
        return CGColor(red: r, green: g, blue: b, alpha: alpha)
    }
    
    /// Create ``CGColor`` from a hex string.
    ///
    /// The format of the string should be:
    /// - Starts with '#'
    /// - Has 6 numbers(rgb) or 8 numbers(argb), like #AARRGGBB or #RRGGBB
    static func create(hexString: String?) -> CGColor? {
        guard let hexString = hexString else {
            return nil
        }
        
        if !hexString.hasPrefix("#") {
            return nil
        }
        
        let start = hexString.index(hexString.startIndex, offsetBy: 1)
        let hexColor = String(hexString[start...])
        
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let a: CGFloat
            if hexColor.count == 8 {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            } else {
                a = 1.0
            }
            let r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x000000ff) / 255
            
            return CGColor(red: r, green: g, blue: b, alpha: a)
        } else {
            return nil
        }
    }
    
    /// Get the hex string like #AARRGGBB.
    func toHexString(withAlpha: Bool = false) -> String? {
        guard let components = self.components else {
            return nil
        }
        
        if components.count != 4 && components.count != 3 {
            return nil
        }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        
        let a: CGFloat
        if components.count == 4 {
            a = components[3]
        } else {
            a = 1.0
        }
        
        let rHex = String(format: "%02X", UInt8(r * 255))
        let gHex = String(format: "%02X", UInt8(g * 255))
        let bHex = String(format: "%02X", UInt8(b * 255))
        let aHex = String(format: "%02X", UInt8(a * 255))
        
        if withAlpha {
            return "#\(aHex)\(rHex)\(gHex)\(bHex)"
        } else {
            return "#\(rHex)\(gHex)\(bHex)"
        }
    }
}
