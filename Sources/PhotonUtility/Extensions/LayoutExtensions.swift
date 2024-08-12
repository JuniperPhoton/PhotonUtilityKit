//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/8/10.
//

import SwiftUI

/// Convenient extensions to create ``EdgeInsets``.
public extension EdgeInsets {
    static func createUnified(inset: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)
    }
    
    static func createVertical(inset: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0)
    }
    
    static func createHorizontal(inset: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset)
    }
    
    static func create(_ top: CGFloat, _ leading: CGFloat, _ bottom: CGFloat, _ trailing: CGFloat) -> EdgeInsets {
        return EdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
}

extension CGSize: @retroactive CustomStringConvertible {
    public var description: String {
        return "\(self.width) x \(self.height)"
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
extension ProposedViewSize: @retroactive CustomStringConvertible {
    public var description: String {
        return "\(String(describing: self.width)) x \(String(describing: self.height))"
    }
}
