//
//  View+BackPress.swift
//  PhotonCamSharedUtils
//
//  Created by juniperphoton on 2025/6/20.
//
import SwiftUI

#if canImport(UIKit)
public extension View {
    /// Handle back-pressed event by pressing the escape key from keyboard.
    @ViewBuilder
    func onBackPressed(enabled: Bool = true, action: @escaping () -> Void) -> some View {
        self.background {
            KeyHandlerView(supportedKeys: enabled ? [.inputEscape] : []) { _ in
                action()
            }
        }
    }
    
    /// Handle key-pressing events from keyboard.
    @ViewBuilder
    func onPressed(for keys: Set<SystemKey>, action: @escaping (SystemKey) -> Void) -> some View {
        self.background {
            KeyHandlerView(supportedKeys: keys, action: action)
        }
    }
    
    /// Handle a specific key-pressing event from keyboard.
    @ViewBuilder
    func onPressed(for key: SystemKey, action: @escaping () -> Void) -> some View {
        self.background {
            KeyHandlerView(supportedKeys: [key]) { pressed in
                if pressed == key {
                    action()
                }
            }
        }
    }
}

public enum SystemKey {
    case inputEscape
    case inputArrowUp
    case inputArrowDown
    case inputArrowLeft
    case inputArrowRight
    case inputDelete
    
    var uiKeyCommand: String {
        switch self {
        case .inputEscape:
            return UIKeyCommand.inputEscape
        case .inputArrowUp:
            return UIKeyCommand.inputUpArrow
        case .inputArrowDown:
            return UIKeyCommand.inputDownArrow
        case .inputArrowLeft:
            return UIKeyCommand.inputLeftArrow
        case .inputArrowRight:
            return UIKeyCommand.inputRightArrow
        case .inputDelete:
            return UIKeyCommand.inputDelete
        }
    }
}

class KeyHandlerUIView: UIView {
    var supportedKeys: Set<SystemKey> = []
    var action: ((SystemKey) -> Void)? = nil
    
    override var canBecomeFirstResponder: Bool {
        return !supportedKeys.isEmpty
    }
    
    override var keyCommands: [UIKeyCommand]? {
        supportedKeys.map { key in
            UIKeyCommand(input: key.uiKeyCommand, modifierFlags: [], action: #selector(handleKeyPressed))
        }
    }
    
    @objc private func handleKeyPressed(command: UIKeyCommand) {
        var mappedKey: SystemKey? = nil
        
        if command.input == UIKeyCommand.inputEscape {
            mappedKey = .inputEscape
        } else if command.input == UIKeyCommand.inputUpArrow {
            mappedKey = .inputArrowUp
        } else if command.input == UIKeyCommand.inputDownArrow {
            mappedKey = .inputArrowDown
        } else if command.input == UIKeyCommand.inputLeftArrow {
            mappedKey = .inputArrowLeft
        } else if command.input == UIKeyCommand.inputRightArrow {
            mappedKey = .inputArrowRight
        } else if command.input == UIKeyCommand.inputDelete {
            mappedKey = .inputDelete
        }
        
        if let key = mappedKey, let action = action {
            action(key)
        }
    }
}

struct KeyHandlerView: UIViewRepresentable {
    var supportedKeys: Set<SystemKey>
    var action: (SystemKey) -> Void
    
    func makeUIView(context: Context) -> KeyHandlerUIView {
        return KeyHandlerUIView()
    }
    
    func updateUIView(_ uiView: KeyHandlerUIView, context: Context) {
        uiView.action = action
        uiView.supportedKeys = supportedKeys
        if !supportedKeys.isEmpty {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }
}
#endif
