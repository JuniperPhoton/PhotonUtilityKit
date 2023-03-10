//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/2/23.
//

import Foundation

#if canImport(WidgetKit)
import WidgetKit
#endif

public class WidgetCenterCompact {
    public static let shared = WidgetCenterCompact()
    
    private init() {
        // empty
    }
    
    public func reloadAllTimelines() {
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
#endif
    }
}
