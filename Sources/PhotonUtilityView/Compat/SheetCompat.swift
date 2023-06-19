//
//  SheetCompat.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2023/4/18.
//

import SwiftUI
import PhotonUtility

fileprivate func shouldApplyCompat() -> Bool {
    return DeviceCompat.isOS2022AndAbove()
}

@available(iOS 15.0, macOS 12.0, *)
struct SheetCompat<ViewContent: View, Item: Identifiable>: ViewModifier {
    @Environment(\.dismiss) var dismiss
    
    let item: Binding<Item?>
    let onDismiss: (() -> Void)?
    let content: (Item) -> ViewContent
    
    func body(content: Content) -> some View {
        Group {
            if shouldApplyCompat() {
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                    content
                        .sheet(item: item, onDismiss: onDismiss, content: { item in
                            self.content(item).presentationDetents([.fraction(0.999)])
                        })
                } else {
                    content
                        .sheet(item: item, onDismiss: onDismiss, content: self.content)
                }
            } else {
                content
                    .sheet(item: item, onDismiss: onDismiss, content: self.content)
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct SheetCompatWithIsPrestented<ViewContent: View>: ViewModifier {
    @Environment(\.dismiss) var dismiss
    
    let isPresented: Binding<Bool>
    let onDismiss: (() -> Void)?
    let content: () -> ViewContent
    
    func body(content: Content) -> some View {
        Group {
            if shouldApplyCompat() {
                if #available(iOS 16.0, macOS 13.0, tvOS 16.0, *) {
                    content
                        .sheet(isPresented: isPresented, onDismiss: onDismiss) {
                            self.content().presentationDetents([.fraction(0.999)])
                        }
                } else {
                    content
                        .sheet(isPresented: isPresented, onDismiss: onDismiss, content: self.content)
                }
            } else {
                content
                    .sheet(isPresented: isPresented, onDismiss: onDismiss, content: self.content)
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension View {
    public func sheetCompat<ViewContent: View, Item: Identifiable>(item: Binding<Item?>,
                                                                   onDismiss: (() -> Void)? = nil,
                                                                   @ViewBuilder content: @escaping (Item) -> ViewContent) -> some View {
        self.modifier(SheetCompat(item: item, onDismiss: onDismiss, content: content))
    }
    
    public func sheetCompat<ViewContent: View>(isPresented: Binding<Bool>,
                                               onDismiss: (() -> Void)? = nil,
                                               @ViewBuilder content: @escaping () -> ViewContent) -> some View {
        self.modifier(SheetCompatWithIsPrestented(isPresented: isPresented, onDismiss: onDismiss, content: content))
    }
}
