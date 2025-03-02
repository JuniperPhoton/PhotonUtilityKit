import SwiftUI

public extension View {
    /// Compat version of using ``NavigationTransition/zoom(sourceID:in:)`` for``View/navigationTransition(_:)``.
    @ViewBuilder
    func navigationZoomedTransitionCompat<ID: Hashable>(_ soruceID: ID, _ namespace: Namespace.ID) -> some View {
#if os(iOS)
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            self.navigationTransition(.zoom(sourceID: soruceID, in: namespace))
        } else {
            self
        }
#else
        self
#endif
    }
    
    /// Compat version of using ``View/matchedTransitionSource(sourceID:in:)``.
    @ViewBuilder
    func matchedTransitionSourceCompat<ID: Hashable>(_ sourceID: ID, _ namespace: Namespace.ID) -> some View {
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            self.matchedTransitionSource(id: sourceID, in: namespace)
        } else {
            self
        }
    }
    
    /// Compat version of using ``View/matchedTransitionSource(sourceID:in:configuration:)``.
    @ViewBuilder
    func matchedTransitionSourceCompat<ID: Hashable>(
        _ sourceID: ID,
        _ namespace: Namespace.ID,
        configuration: TransitionSourceConfigurationCompat
    ) -> some View {
#if os(iOS)
        if #available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *) {
            self.matchedTransitionSource(id: sourceID, in: namespace) { configure in
                configuration.configure(configure)
            }
        } else {
            self
        }
#else
        self
#endif
    }
}

public struct TransitionSourceConfigurationCompat {
    struct Shadow {
        let color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)
        let radius: CGFloat
        let x: CGFloat = 0
        let y: CGFloat = 0
    }
    
    let backgroundColor: Color
    let clipShape: RoundedRectangle
    let shadow: Shadow
    
    @available(iOS 18.0, macOS 15.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
    func configure(_ sourceConfiguration: EmptyMatchedTransitionSourceConfiguration) -> some MatchedTransitionSourceConfiguration {
        sourceConfiguration.background(backgroundColor)
            .clipShape(clipShape)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
