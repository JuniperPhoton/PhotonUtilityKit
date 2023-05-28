//
//  AppPasteboard.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/2/11.
//

import Foundation
import UniformTypeIdentifiers

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public class AppPasteboard {
    public static let shared = AppPasteboard()
    
    private init() {
        // ignored
    }
    
    /// Copy a text to the paste board.
    public func copyToPasteBoard(string: String) {
#if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(string, forType: .string)
#elseif os(iOS)
        UIPasteboard.general.setValue(string,
                                      forPasteboardType: UTType.plainText.identifier)
#endif
    }
    
    public func getPasteBoardTextString() -> String? {
#if os(macOS)
        return NSPasteboard.general.string(forType: .string)
#elseif os(iOS)
        return UIPasteboard.general.string
#endif
    }
}
