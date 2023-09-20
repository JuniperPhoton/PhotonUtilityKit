//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/6/20.
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit
#endif

/// An ObservableObject providing keyboard frame observation.
/// On iOS and iPadOS, you subscribe to the changed of ``keyboardFrame`` to perform action.
///
/// On macOS or any other platforms, the ``keyboardFrame`` is always .zero.
public class KeyboardFrameObserver: ObservableObject {
    @Published public var keyboardFrame: CGRect = .zero
    
    public init() {
#if os(iOS)
        NotificationCenter.default.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
#endif
    }
    
    deinit {
#if os(iOS)
        NotificationCenter.default.removeObserver(self)
#endif
    }
    
#if os(iOS)
    @objc private func willHide() {
        self.keyboardFrame = .zero
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        self.keyboardFrame = keyboardScreenEndFrame
    }
#endif
}

/// Hide keyboard globally by sending resignFirstResponder action on iOS and iPadOS.
/// On macOS, this method will do nothing.
public func hideKeyboardGlobally() {
#if os(iOS)
    UIApplication
        .shared
        .sendAction(#selector(UIApplication.resignFirstResponder),
                    to: nil, from: nil, for: nil)
#endif
}
