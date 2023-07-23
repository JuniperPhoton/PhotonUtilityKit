//
//  TextViewBridge.swift
//  PhotonAITranslator
//
//  Created by Photon Juniper on 2023/4/26.
//

import SwiftUI
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

#if os(macOS)
/// A scrollable text view for macOS.
/// It wraps ``NSTextView`` and ``NSScrollView`` to achieve the best performance for displaying a large text.
///
/// The SwiftUI's ``Text`` view is great for displaying a small number of text.
/// But if you are implementing a text view to display frequently updated text, like what ChatGPT does,
/// SwiftUI's ``Text`` will introduce performance overhead and slow down your app.
///
/// You use ``text`` property to pass the text to be displayed.
/// Set ``autoScrollToBottom`` to true if you would like the text to scroll down to bottom automatically while updating.
public struct ScrollableTextViewCompat: NSViewRepresentable {
    public static func dismantleNSView(_ nsView: NSScrollView, coordinator: TextViewCoordinator) {
        coordinator.unregister()
    }
    
    public class TextViewCoordinator: NSObject {
        fileprivate var autoScrollToBottom = true
        
        func unregister() {
            NotificationCenter.default.removeObserver(self)
        }
        
        func register() {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(onScroll),
                                                   name: NSScrollView.willStartLiveScrollNotification,
                                                   object: nil)
        }
        
        @objc
        func onScroll() {
            self.autoScrollToBottom = false
        }
    }
    
    public let text: NSAttributedString
    public let foregroundColorName: String?
    public let contentInsets: EdgeInsets?
    public let autoScrollToBottom: Bool
    
    public init(text: NSAttributedString,
                foregroundColorName: String?,
                autoScrollToBottom: Bool,
                contentInsets: EdgeInsets? = nil) {
        self.text = text
        self.foregroundColorName = foregroundColorName
        self.contentInsets = contentInsets
        self.autoScrollToBottom = autoScrollToBottom
    }
    
    public init(text: String,
                foregroundColorName: String?,
                autoScrollToBottom: Bool,
                contentInsets: EdgeInsets? = nil) {
        self.text = NSAttributedString(string: text)
        self.foregroundColorName = foregroundColorName
        self.contentInsets = contentInsets
        self.autoScrollToBottom = autoScrollToBottom
    }
    
    public func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.textStorage?.setAttributedString(self.text)
        textView.drawsBackground = false
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.isEditable = false
        
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        
        if let insets = contentInsets {
            scrollView.automaticallyAdjustsContentInsets = false
            scrollView.contentInsets = NSEdgeInsets(top: insets.top,
                                                    left: insets.leading,
                                                    bottom: insets.bottom,
                                                    right: insets.trailing)
        }
                
        if autoScrollToBottom {
            context.coordinator.register()
        }
        
        return scrollView
    }
    
    public func makeCoordinator() -> TextViewCoordinator {
        let coordinator = TextViewCoordinator()
        coordinator.autoScrollToBottom = autoScrollToBottom
        return coordinator
    }
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        let scrollView = nsView
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }
        textView.textStorage?.setAttributedString(self.text)
        setLineSpacing(for: textView)
        textView.autoresizingMask = [.width, .height]
        
        if context.coordinator.autoScrollToBottom {
            scrollView.documentView?.scroll(.init(x: 0, y: textView.bounds.height))
        }
    }
    
    private func setLineSpacing(for textView: NSTextView) {
        // Get the text storage and the full range of text
        guard let textStorage = textView.textStorage else { return }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        
        // Create a mutable paragraph style with the desired line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        // Apply the paragraph style to the text storage
        textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        if let colorName = foregroundColorName,
           let color = NSColor(named: colorName) {
            textStorage.foregroundColor = color
        }
    }
}
#elseif os(iOS)
/// A scrollable text view for iOS.
/// Internally it wraps a ``UITextView``.
/// See the comments above for more details.
public struct ScrollableTextViewCompat: UIViewRepresentable {
    public class TextViewCoordinator: NSObject, UITextViewDelegate {
        fileprivate var autoScrollToBottom = true
                
        @objc
        func onScroll() {
            self.autoScrollToBottom = false
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            autoScrollToBottom = false
        }
    }
    
    let text: NSAttributedString
    let foregroundColorName: String?
    let autoScrollToBottom: Bool
    let contentInsets: EdgeInsets?
    
    public init(text: NSAttributedString,
                foregroundColorName: String?,
                autoScrollToBottom: Bool,
                contentInsets: EdgeInsets? = nil) {
        self.text = text
        self.foregroundColorName = foregroundColorName
        self.autoScrollToBottom = autoScrollToBottom
        self.contentInsets = contentInsets
    }
    
    public init(text: String,
                foregroundColorName: String?,
                autoScrollToBottom: Bool,
                contentInsets: EdgeInsets? = nil) {
        self.text = NSAttributedString(string: text)
        self.foregroundColorName = foregroundColorName
        self.autoScrollToBottom = autoScrollToBottom
        self.contentInsets = contentInsets
    }
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.attributedText = self.text
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.delegate = context.coordinator
        
        if let insets = contentInsets {
            textView.contentInset = UIEdgeInsets(top: insets.top,
                                                 left: insets.leading,
                                                 bottom: insets.bottom,
                                                 right: insets.trailing)
        }
        return textView
    }
    
    public func makeCoordinator() -> TextViewCoordinator {
        let coordinator = TextViewCoordinator()
        coordinator.autoScrollToBottom = autoScrollToBottom
        return coordinator
    }
    
    public func updateUIView(_ uiView: UITextView, context: Context) {
        setText(for: uiView)
        
        if context.coordinator.autoScrollToBottom {
            uiView.scrollRangeToVisible(NSRange(location: self.text.length - 2, length: 1))
        }
    }
    
    private func setText(for textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let attributedString = NSMutableAttributedString(attributedString: self.text)
        let fullRange = NSRange(location: 0, length: attributedString.length)

        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle,
                                      range: fullRange)
        
        if let colorName = foregroundColorName,
           let color = UIColor(named: colorName) {
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color,
                                          range: fullRange)
        }
        
        attributedString.addAttribute(NSAttributedString.Key.font,
                                      value: UIFont.systemFont(ofSize: UIFont.labelFontSize),
                                      range: fullRange)
        textView.attributedText = attributedString
    }
}
#endif
