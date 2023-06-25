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
#if canImport(UIKit)
        NotificationCenter.default.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
#endif
    }
    
    deinit {
#if canImport(UIKit)
        NotificationCenter.default.removeObserver(self)
#endif
    }
    
#if canImport(UIKit)
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
