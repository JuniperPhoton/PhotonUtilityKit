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
#if !os(tvOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
            self.sharedBackgroundVisibility(show ? .visible : .hidden)
        } else {
            self
        }
#else
        self
#endif
    }
}

public extension ToolbarItemGroup {
    @ToolbarContentBuilder
    func sharedBackgroundHiddenIfAvailable() -> some ToolbarContent {
        sharedBackgroundVisibilitySettingIfAvailable(show: false)
    }
    
    @ToolbarContentBuilder
    func sharedBackgroundVisibilitySettingIfAvailable(show: Bool) -> some ToolbarContent {
#if !os(tvOS)
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
            self.sharedBackgroundVisibility(show ? .visible : .hidden)
        } else {
            self
        }
#else
        self
#endif
    }
}

public extension ToolbarContent {
    /// Prefers the vertical bar on iPhone Duo. No-op on other platforms.
    @ToolbarContentBuilder
    func preferVerticalBar() -> some ToolbarContent {
#if os(iOS)
        if #available(iOS 27.1, *) {
            self.axisBehavior(.verticalPreferred)
        } else {
            self
        }
#else
        self
#endif
    }
    
    /// Keeps the item in the horizontal bar on iPhone Duo. No-op on other platforms.
    @ToolbarContentBuilder
    func horizontalOnlyToolbar() -> some ToolbarContent {
#if os(iOS)
        if #available(iOS 27.1, *) {
            self.axisBehavior(.horizontalOnly)
        } else {
            self
        }
#else
        self
#endif
    }
}

public extension View {
    @ContentBuilder
    func toolbarMinimizationBehaviorNever() -> some View {
#if os(iOS)
        if #available(iOS 27.0, *) {
            self.toolbarMinimizationBehavior(.never)
        } else {
            self
        }
#else
        self
#endif
    }
}
