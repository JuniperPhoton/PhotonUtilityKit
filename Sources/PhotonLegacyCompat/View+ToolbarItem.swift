//
//  View+ToolbarItem.swift
//  PhotonUtilityKit
//
//  Created by juniperphoton on 9/20/25.
//
import SwiftUI

public extension ToolbarItem {
    @ToolbarContentBuilder
    func sharedBackgroundHiddenIfAvailable() -> some ToolbarContent {
        sharedBackgroundVisibilitySettingIfAvailable(show: false)
    }
    
    @ToolbarContentBuilder
    func sharedBackgroundVisibilitySettingIfAvailable(show: Bool) -> some ToolbarContent {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.sharedBackgroundVisibility(show ? .visible : .hidden)
        } else {
            self
        }
    }
}
