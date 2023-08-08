//
//  SheetCompat.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2023/4/18.
//

import SwiftUI
import PhotonUtility

/// Use this modifier to present a sheet without encountering the following issue:
/// - First present a sheet using .sheet(item:_:_)
/// - Then go back to the home screen of iPhone or iPad
/// - Return to the app, dismiss the presented sheet
/// - The views at the top of the root view, can't response to hit test even thought it looks right
public extension View {
    func sheetCompat<ViewContent: View, Item: Identifiable>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)?,
        @ViewBuilder content: @escaping (Item) -> ViewContent
    ) -> some View {
        self.sheet(item: item, onDismiss: {
            onDismiss?()
            fixContentViewTransformIssue()
        }, content: content)
    }
    
    func sheetCompat<ViewContent: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> ViewContent
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: {
            onDismiss?()
            fixContentViewTransformIssue()
        }, content: content)
    }
}

private func fixContentViewTransformIssue() {
#if os(iOS)
    // In case someone is not using Scene based lifecycle, we still use this deprecated
    // method to get the window
    UIApplication.shared.windows.forEach { window in
        guard let view = window.rootViewController?.view else {
            return
        }
        
        view.transform = CGAffineTransform(translationX: 0, y: 0.1)
        view.transform = CGAffineTransform.identity
    }
#endif
}
