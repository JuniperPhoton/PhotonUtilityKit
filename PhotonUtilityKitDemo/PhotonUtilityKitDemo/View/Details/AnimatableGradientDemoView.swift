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
        VStack {
            let from = Gradient(colors: [.accentColor, .red, .green])
            let to = Gradient(colors: [.green, .orange, .gray])
            
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
            
            Button("Animate") {
                withAnimation(.easeOut) {
                    self.progress = self.progress == 1.0 ? 0.0 : 1.0
                }
            }.padding()
        }
        .padding()
    }
}
