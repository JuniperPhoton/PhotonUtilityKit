//
//  AppTips.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/8/8.
//

import Foundation

/// Describe the content of a tips.
public protocol AppTipContent: Equatable {
    /// The key acts as a identifier of a tips kind
    static var key: String { get }
    
    /// The main text to be displayed in the popover
    var text: String { get }
    
    /// The icon above the text. If it's nil, the icon won't be displayed
    var icon: String? { get }
        
    /// The associated object key of this tip. Used to identify a specifiy view item.
    /// For example, views in a List should have different ``associatedObjectKey``
    /// while they may have the same ``key``
    var associatedObjectKey: String { get }
}

public extension AppTipContent {
    var isEmpty: Bool {
        type(of: self) == EmptyAppTipContent.self
    }
}

/// An object to publish and recieve tips changes.
/// You don't create this object manually, use ``shared`` to get the default instance.
///
/// Use ``enqueueTip`` or ``enqueueTipIfNotShown(_:setShown:)`` to publish a tip.
/// Use ``currentTipContent`` to receive changes.
///
/// In your view, use ``View/popoverTips`` to show tips.
public class AppTipsCenter: ObservableObject {
    static public let shared = AppTipsCenter()
    
    @Published public private(set) var currentTipContent: (any AppTipContent) = EmptyAppTipContent()
    
    private var tipContents: [any AppTipContent] = []
    
    private init() {
        // empty
    }
    
    /// Enqueue a tip of it's not shown before.
    /// The tip passed here is not guaranteed to be displayed immediately, which the word "enqueue" would implies that.
    /// If there is a tip being shown, this tip will be shown after that one is dismissed.
    ///
    /// - parameter setShown: Whether to set shown in the user defaults or not.
    public func enqueueTipIfNotShown(_ content: any AppTipContent, setShown: Bool = true) {
        if AppTipsPreference.shared.isTipShown(key: type(of: content).key) {
            print("AppTipsCenter enqueueTipIfNotShown but is shown \(type(of: content).key)")
            return
        }
        
        enqueueTip(content, setShown: setShown)
    }
    
    /// Enqueue a tip.
    /// The tip passed here is not guaranteed to be displayed immediately, which the word "enqueue" would implies that.
    /// If there is a tip being shown, this tip will be shown after that one is dismissed.
    ///
    /// - parameter setShown: Whether to set shown in the user defaults or not.
    public func enqueueTip(_ content: any AppTipContent, setShown: Bool = true) {
        print("AppTipsCenter enqueue tip \(type(of: content).key)")

        let contains = tipContents.first { type(of: $0).key == type(of: content).key } != nil
        if contains {
            print("AppTipsCenter enqueue tip \(type(of: content).key) but already queued")
            return
        }
        
        tipContents.append(content)
        showNextIfEmpty(setShown: setShown)
    }
    
    func showNextIfEmpty(setShown: Bool) {
        if type(of: currentTipContent) == EmptyAppTipContent.self {
            if !tipContents.isEmpty {
                let first = tipContents.removeFirst()
                currentTipContent = first
                
                if setShown {
                    AppTipsPreference.shared.setTipShown(key: type(of: first).key)
                }
                
                print("AppTipsCenter showNext tip: \(currentTipContent)")
            }
        }
    }
    
    func resetToEmpty() {
        currentTipContent = EmptyAppTipContent()
        print("AppTipsCenter reset currentTipContent")
    }
}

/// An object to manage whether a tip is shown or not.
/// You don't create this object manually, use ``shared`` to get the default instance.
public class AppTipsPreference {
    static public let shared = AppTipsPreference()
    
    private var keys: Set<String> = Set<String>()

    private init() {
        // empty
    }
    
    /// Register a key refering to a tip.
    /// By doing so when you call ``resetAll`` the key will be removed from the UserDefaults.
    public func register(tips: any AppTipContent.Type...) {
        for tip in tips {
            self.keys.insert(tip.key)
        }
    }
    
    /// Check if a tip with the key is already shown or not.
    public func isTipShown(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key, defaultValue: false)
    }
    
    /// Set a tip with the key is already shown.
    public func setTipShown(key: String) {
        UserDefaults.standard.set(true, forKey: key)
    }
    
    public func resetAll() {
        self.keys.forEach { key in
            UserDefaults.standard.set(false, forKey: key)
        }
    }
}

private struct EmptyAppTipContent: AppTipContent {
    static var key: String = "EmptyAppTipContent"

    var text: String = ""
    var icon: String? = nil
    var associatedObjectKey: String = "empty"
}
