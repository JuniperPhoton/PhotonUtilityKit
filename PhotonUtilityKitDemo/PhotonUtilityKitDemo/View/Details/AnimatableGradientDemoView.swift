//
//  AnimatableGradientExample.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/10.
//

import SwiftUI
import PhotonUtilityView

struct AnimatableGradientDemoView: View {
    @State private var progress: CGFloat = 0
    
    var body: some View {
        let from = Gradient(colors: [.accentColor, .red, .green])
        let to = Gradient(colors: [.green, .orange, .gray])
        
        VStack {
            Text("Capsule linear")
                .font(.title.bold())
                .foregroundColor(.white)
                .padding()
                .padding()
                .background(
                    Capsule()
                        .fillAnimatableGradient(fromGradient: from,
                                                toGradient: to,
                                                progress: progress) { gradient in
                                                    LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .trailing)
                                                }
                )

            Text("RoundedRectangle angular")
                .font(.title.bold())
                .foregroundColor(.white)
                .padding()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fillAnimatableGradient(fromGradient: from,
                                                toGradient: to,
                                                progress: progress) { gradient in
                                                    AngularGradient(gradient: gradient, center: .center, angle: .degrees(progress == 1.0 ? 30 : 0.0))
                                                }
                )
            
            HStack {
                Text("Circle")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .addShadow(x: 0, y: 0)
                    .padding()
                    .padding()
                    .background(
                        Circle()
                            .fillAnimatableGradient(fromGradient: Gradient(colors: [Color("ThemeAwareColor"), Color.white]),
                                                    toGradient:Gradient(colors: [Color("ThemeAwareColor"), Color.white]),
                                                    progress: progress) { gradient in
                                                        LinearGradient(gradient: gradient, startPoint: progress == 1.0 ? .bottomTrailing : .topLeading, endPoint: .trailing)
                                                    }
                    )
            }
            
            Button("Animate") {
                withAnimation(.easeOut(duration: 5.0).repeatForever(autoreverses: true)) {
                    self.progress = self.progress == 1.0 ? 0.0 : 1.0
                }
            }.padding()
        }
        .matchParent()
        .background(
            ZStack {
                Rectangle()
                    .fillAnimatableGradient(
                        fromGradient: to,
                        toGradient: from,
                        progress: progress,
                        fillShape: { gradient in
                            RadialGradient(gradient: gradient, center: progress == 1.0 ? .top : .bottomTrailing, startRadius: progress == 1.0 ? 600 : 180, endRadius: 1000)
                        }
                    )
                    .blur(radius: progress == 1.0 ? 30 : 12, opaque: true)
                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                
                Rectangle()
                    .fillAnimatableGradient(
                        fromGradient: from,
                        toGradient: to,
                        progress: progress,
                        fillShape: { gradient in
                            AngularGradient(gradient: gradient, center: progress == 1.0 ? .init(x: 0.2, y: 0.4) : .center, angle: .degrees(progress == 1.0 ? 320 : 470))
                        }
                    )
                    .blur(radius: progress == 1.0 ? 30 : 12, opaque: true)
                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
                    .blendMode(.lighten)
            }.drawingGroup().ignoresSafeArea().opacity(0.6)
        )
    }
}
