//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/3/11.
//

import Foundation

#if canImport(AppKit)
import AppKit

public extension NSScrollView {
    /// From: https://fpposchmann.de/animate-nsviews-scrolltovisible/
    func scroll(toRect rect: CGRect, animationDuration duration: Double = 0.3) {
        let clipView = self.contentView           // and thats its clip view
        
        var newOrigin = clipView.bounds.origin          // make a copy of the current origin
        newOrigin.x = min(newOrigin.x, rect.origin.x)
        
        if rect.origin.x > newOrigin.x + clipView.bounds.width - rect.width {  // we are too far to the left
            newOrigin.x = rect.origin.x - clipView.bounds.width + rect.width   // correct that
        }
        
        newOrigin.y = min(newOrigin.y, rect.origin.y)
        
        if rect.origin.y > newOrigin.y + clipView.bounds.height - rect.height {    // we are too high
            newOrigin.y = rect.origin.y - clipView.bounds.height + rect.height // correct that
        }
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = .init(name: .easeOut)
            
            clipView.animator().setBoundsOrigin(newOrigin)  // set the new origin with animation
            self.reflectScrolledClipView(clipView)    // and inform the scroll view about that
        }
    }
}
#endif
