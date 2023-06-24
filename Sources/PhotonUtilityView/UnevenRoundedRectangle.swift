//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/6/20.
//

import Foundation
import SwiftUI

/// A SwiftUI shape that has uneven rounded radius.
public struct UnevenRoundedRectangle: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat
    
    /// Initialize with all uneven rounded radius.
    public init(topLeft: CGFloat,
                topRight: CGFloat,
                bottomLeft: CGFloat,
                bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
    
    /// Initialize with uneven rounded radius of top and bottom.
    public init(top: CGFloat, bottom: CGFloat) {
        self.init(topLeft: top, topRight: top, bottomLeft: bottom, bottomRight: bottom)
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: CGPoint(x: tl.x + topLeft, y: tl.y))
        path.addLine(to: CGPoint(x: tr.x - topRight, y: tr.y))
        path.addArc(center: CGPoint(x: tr.x - topRight, y: tr.y + topRight), radius: topRight, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: br.x, y: br.y - bottomRight))
        path.addArc(center: CGPoint(x: br.x - bottomRight, y: br.y - bottomRight), radius: bottomRight, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl.x + bottomLeft, y: bl.y))
        path.addArc(center: CGPoint(x: bl.x + bottomLeft, y: bl.y - bottomLeft), radius: bottomLeft, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: tl.x, y: tl.y + topLeft))
        path.addArc(center: CGPoint(x: tl.x + topLeft, y: tl.y + topLeft), radius: topLeft, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        return path
    }
}
