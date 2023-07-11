//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/10.
//

import SwiftUI

public extension Shape {
    /// Fill this shape with animatable gradient, specified by ``fromGradient`` and ``toGradient``.
    /// You use ``fromGradient`` and ``toGradient`` to specify the gradient to animate,
    /// those Gradient should have the same colors/stops count.
    ///
    /// - parameter progress: Controls the animating progress from ``fromGradient`` to ``toGradient``.
    /// - parameter fillShape: A block to return a ``ShapeStyle`` given a ``Gradient``, like ``LinearGradient`` or ``AngularGradient``.
    ///
    /// An example:
    ///
    /// ```swift
    ///     Capsule()
    ///         .fillAnimatableGradient(fromGradient: .init(colors: [.accentColor, .red, .green]),
    ///                                 toGradient: .init(colors: [.green, .orange, .gray]),
    ///                                 progress: progress) { gradient in
    ///             LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .trailing)
    ///         }
    /// ```
    func fillAnimatableGradient<Style: ShapeStyle>(fromGradient: Gradient,
                                                   toGradient: Gradient,
                                                   progress: CGFloat,
                                                   fillShape: @escaping (Gradient) -> Style) -> some View {
        return ColorSchemeAwareView {
            // We must resolve the color to the current trait collection here
            // Each time the ShapeWrapper updates(due to colorScheme changed), we must resolve the colors.
            let resolvedFromGradient = Gradient(stops: fromGradient.stops.map { stop in
                Gradient.Stop(color: stop.color.resolve(), location: stop.location)
            })
            
            let resolvedToGradient = Gradient(stops: toGradient.stops.map { stop in
                Gradient.Stop(color: stop.color.resolve(), location: stop.location)
            })
            
            return self.modifier(AnimatableGradientShape(
                shape: self,
                fromGradient: resolvedFromGradient,
                toGradient: resolvedToGradient,
                progress: progress,
                fillShape: fillShape)
            )
        }
    }
}

/// We use a wrapper to wrap the rendering view.
/// Inside we observe colorScheme changed and recalculate the content view.
fileprivate struct ColorSchemeAwareView<V: View>: View {
    /// On iOS, to make this ViewModifier update on colorScheme changed, we need to declare it here.
    /// On macOS, there is no such issue.
    @Environment(\.colorScheme) private var colorScheme
    
    let view: () -> V
    
    init(_ view: @escaping () -> V) {
        self.view = view
    }
    
    var body: some View {
        view()
    }
}

/// We use ``AnimatableModifier`` if we still want to support macOS 11.0 in Swift Package.
///
/// If we change ``AnimatableModifier`` to ``View`` + ``Animatable``, the animation won't work, even on newer macOS version
/// with this Swift Package targeting to ``.macOS(.v11)``.
fileprivate struct AnimatableGradientShape<S: Shape, Style: ShapeStyle>: AnimatableModifier {
    let shape: S
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0
    
    let fillShape: (Gradient) -> Style
    
    public var animatableData: CGFloat {
        get {
            progress
        }
        set {
            progress = newValue
        }
    }
    
    public init(shape: S,
                fromGradient: Gradient,
                toGradient: Gradient,
                progress: CGFloat,
                fillShape: @escaping (Gradient) -> Style) {
        self.shape = shape
        self.fromGradient = fromGradient
        self.toGradient = toGradient
        self.progress = progress
        self.fillShape = fillShape
    }
    
    public func body(content: Content) -> some View {
        shape.fill(fillShape(currentGradient))
    }
    
    private var currentGradient: Gradient {
        var gradientColors = [Color]()
        
        for i in 0..<fromGradient.stops.count {
            let fromColor = fromGradient.stops[i].color
            let toColor = toGradient.stops[i].color
            gradientColors.append(colorMixer(fromColor: fromColor,
                                             toColor: toColor, progress: animatableData))
        }
        
        return Gradient(colors: gradientColors)
    }
}

public extension Color {
    /// Resolve this SwiftUI color to the Color with RGBA components based on the current environment.
    func resolve() -> Color {
        let cgColorComponents: [CGFloat]
#if canImport(UIKit)
        let platformColor = UIColor(self)
        let cgColor = platformColor.cgColor
        guard let components = cgColor.components else {
            return self
        }
        cgColorComponents = components
#elseif canImport(AppKit)
        let platformColor = NSColor(self)
        let cgColor = platformColor.cgColor
        guard let components = cgColor.components else {
            return self
        }
        cgColorComponents = components
#else
        return self
#endif
        
        return Color(red: Double(cgColorComponents[0]),
                     green: Double(cgColorComponents[1]),
                     blue: Double(cgColorComponents[2]),
                     opacity: Double(cgColorComponents[3]))
    }
}

fileprivate func colorMixer(fromColor: Color, toColor: Color, progress: CGFloat) -> Color {
    let fromR: CGFloat
    let toR: CGFloat
    
    let fromG: CGFloat
    let toG: CGFloat
    
    let fromB: CGFloat
    let toB: CGFloat
    
    let fromAlpha: CGFloat
    let toAlpha: CGFloat
        
#if canImport(UIKit)
    let fromPlatformColor = UIColor(fromColor)
    guard let fromComponents = fromPlatformColor.cgColor.components else {
        return fromColor
    }
    
    fromR = fromComponents[0]
    fromG = fromComponents[1]
    fromB = fromComponents[2]
    fromAlpha = fromComponents[3]
    
    let toPlatformColor = UIColor(toColor)
    guard let toComponents = toPlatformColor.cgColor.components else {
        return fromColor
    }
    toR = toComponents[0]
    toG = toComponents[1]
    toB = toComponents[2]
    toAlpha = toComponents[3]
#else
    let fromPlatformColor = NSColor(fromColor)
    let toPlatformColor = NSColor(toColor)
    
    guard let fromComponents = fromPlatformColor.cgColor.components else {
        return fromColor
    }
    guard let toComponents = toPlatformColor.cgColor.components else {
        return fromColor
    }
    
    fromR = fromComponents[0]
    fromG = fromComponents[1]
    fromB = fromComponents[2]
    fromAlpha = fromComponents[3]
    
    toR = toComponents[0]
    toG = toComponents[1]
    toB = toComponents[2]
    toAlpha = toComponents[3]
#endif
    
    let red = fromR + (toR - fromR) * progress
    let green = fromG + (toG - fromG) * progress
    let blue = fromB + (toB - fromB) * progress
    let alpha = fromAlpha + (toAlpha - fromAlpha) * progress
    
    return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
}
