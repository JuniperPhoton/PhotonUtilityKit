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
    func fillAnimatableGradient<Style: ShapeStyle>(fromGradient: Gradient,
                                                   toGradient: Gradient,
                                                   progress: CGFloat,
                                                   fillShape: @escaping (Gradient) -> Style) -> some View {
        self.modifier(AnimatableGradientShape(shape: self, fromGradient: fromGradient,
                                              toGradient: toGradient,
                                              progress: progress,
                                              fillShape: fillShape))
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
    
    public init(shape: S, fromGradient: Gradient,
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
        body
    }
    
    public var body: some View {
        shape.fill(fillShape(currentGradient))
    }
    
    private var currentGradient: Gradient {
        var gradientColors = [Color]()
        
        for i in 0..<fromGradient.stops.count {
            gradientColors.append(colorMixer(fromColor: fromGradient.stops[i].color,
                                             toColor: toGradient.stops[i].color, progress: progress))
        }
        
        return Gradient(colors: gradientColors)
    }
}

fileprivate func colorMixer(fromColor: Color, toColor: Color, progress: CGFloat) -> Color {
    let fromR: CGFloat
    let toR: CGFloat
    
    let fromG: CGFloat
    let toG: CGFloat
    
    let fromB: CGFloat
    let toB: CGFloat
    
#if canImport(UIKit)
    let fromUIColor = UIColor(fromColor)
    let toUIColor = UIColor(toColor)
    
    fromR = fromUIColor.cgColor.components![0]
    fromG = fromUIColor.cgColor.components![1]
    fromB = fromUIColor.cgColor.components![2]
    
    toR = toUIColor.cgColor.components![0]
    toG = toUIColor.cgColor.components![1]
    toB = toUIColor.cgColor.components![2]
#else
    let fromNSColor = NSColor(fromColor)
    let toNSColor = NSColor(toColor)
    
    fromR = fromNSColor.cgColor.components![0]
    fromG = fromNSColor.cgColor.components![1]
    fromB = fromNSColor.cgColor.components![2]
    
    toR = toNSColor.cgColor.components![0]
    toG = toNSColor.cgColor.components![1]
    toB = toNSColor.cgColor.components![2]
#endif
    
    let red = fromR + (toR - fromR) * progress
    let green = fromG + (toG - fromG) * progress
    let blue = fromB + (toB - fromB) * progress
    
    return Color(red: Double(red), green: Double(green), blue: Double(blue))
}
