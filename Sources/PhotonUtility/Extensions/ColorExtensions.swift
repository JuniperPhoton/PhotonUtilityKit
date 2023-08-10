//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/8/10.
//

import SwiftUI

public extension Color {
    /// Init a ``Color`` with a hex string.
    /// - parameter hexString: a hex string starts with `#` and has this format: #AARRGGBB or #RRGGBB
    init?(hexString: String?) {
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
            
            self = Color.init(red: r, green: g, blue: b, opacity: a)
        } else {
            return nil
        }
    }
    
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
