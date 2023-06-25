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

public class WidgetCenterCompat {
    public static let shared = WidgetCenterCompat()
    
    private init() {
        // empty
    }
    
    public func reloadAllTimelines() {
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
#endif
    }
}
