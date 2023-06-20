//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/6/20.
//

import Foundation
import SwiftUI

public struct UnevenRoundedRectangle: Shape {
    var topLeftRadius: CGFloat
    var topRightRadius: CGFloat
    var bottomLeftRadius: CGFloat
    var bottomRightRadius: CGFloat
    
    public init(topLeftRadius: CGFloat, topRightRadius: CGFloat, bottomLeftRadius: CGFloat, bottomRightRadius: CGFloat) {
        self.topLeftRadius = topLeftRadius
        self.topRightRadius = topRightRadius
        self.bottomLeftRadius = bottomLeftRadius
        self.bottomRightRadius = bottomRightRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let tl = CGPoint(x: rect.minX, y: rect.minY)
        let tr = CGPoint(x: rect.maxX, y: rect.minY)
        let bl = CGPoint(x: rect.minX, y: rect.maxY)
        let br = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: CGPoint(x: tl.x + topLeftRadius, y: tl.y))
        path.addLine(to: CGPoint(x: tr.x - topRightRadius, y: tr.y))
        path.addArc(center: CGPoint(x: tr.x - topRightRadius, y: tr.y + topRightRadius), radius: topRightRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: br.x, y: br.y - bottomRightRadius))
        path.addArc(center: CGPoint(x: br.x - bottomRightRadius, y: br.y - bottomRightRadius), radius: bottomRightRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl.x + bottomLeftRadius, y: bl.y))
        path.addArc(center: CGPoint(x: bl.x + bottomLeftRadius, y: bl.y - bottomLeftRadius), radius: bottomLeftRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: tl.x, y: tl.y + topLeftRadius))
        path.addArc(center: CGPoint(x: tl.x + topLeftRadius, y: tl.y + topLeftRadius), radius: topLeftRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        return path
    }
}
