//
//  OnChangeCompat.swift
//  PhotonCam
//
//  Created by Photon Juniper on 2024/8/28.
//
import SwiftUI

public extension View {
    /// A compat version of ``View/onChange(of:perform:)`` that takes single parameter.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform: @escaping (_ newValue: V) -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, newValue in
                perform(newValue)
            }
        } else {
            self.onChange(of: value, perform: perform)
        }
    }
    
    /// A compat version of ``View/onChange(of:perform:)`` that takes zero parameter.
    @ViewBuilder
    func onChangeCompat<V: Equatable>(of value: V, perform: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) { _, _ in
                perform()
            }
        } else {
            self.onChange(of: value) { _ in
                perform()
            }
        }
    }
}
