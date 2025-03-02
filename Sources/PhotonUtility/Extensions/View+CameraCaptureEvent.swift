//
//  View+CameraCaptureEventCompat.swift
//  PhotonCamSharedUtils
//
//  Created by JuniperPhoton on 2024/11/19.
//
import SwiftUI
import AVKit

public extension View {
    /// Compat version of ``onCameraCaptureEvent`` on iOS 18.0.
    ///
    /// For prior versions, this modifier does nothing and please use ``CaptureEventRegistration``
    /// to register events.
    @ViewBuilder
    func onCameraCaptureEventCompat(
        isEnabled: Bool = true,
        primaryAction: @escaping () -> Void,
        secondaryAction: @escaping () -> Void
    ) -> some View {
#if os(iOS)
        if #available(iOS 18.0, *) {
            self.onCameraCaptureEvent(isEnabled: isEnabled) { event in
                switch event.phase {
                case .ended:
                    primaryAction()
                default:
                    break
                }
            } secondaryAction: { event in
                switch event.phase {
                case .ended:
                    secondaryAction()
                default:
                    break
                }
            }
        } else {
            self
        }
#else
        self
#endif
    }
}
