//
//  CounterIndexDemoView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/7/28.
//

import SwiftUI
import PhotonUtilityView
import PhotonUtility

fileprivate enum AnimationType: String, CaseIterable {
    case defaultAnimation
    case easeIn
    case easeOut
    case easeInOut
    case spring
    
    func getAnimation(_ duration: Double) -> Animation {
        switch self {
        case .defaultAnimation:
            return .default
        case .easeIn:
            return .easeIn(duration: duration)
        case .easeOut:
            return .easeOut(duration: duration)
        case .easeInOut:
            return .easeInOut(duration: duration)
        case .spring:
            return .interpolatingSpring(stiffness: 100, damping: 170, initialVelocity: 0.4)
        }
    }
}

struct AnimatedNumberDemoView: View {
    @State private var index = 1999
    
    @State private var indexString = "1999"
    
    @State private var duration = 0.3
    @State private var animationType = AnimationType.spring
    
    @State private var code = HighliableCode(code: #"""
    AnimatedGroupNumberView(number: index, transcation: Transaction(animation: .spring()))
        .font(.system(size: 50).monospacedDigit().bold())
        .foregroundColor(.accentColor)
    """#)
    
    var body: some View {
        VStack(spacing: 0) {
            HighliableCodeView(code: code, maxHeight: 100).padding()
            
            if #available(iOS 15.0, macOS 12.0, tvOS 15.0, *) {
                AnimatedGroupNumberView(number: index, transcation: Transaction(animation: animationType.getAnimation(duration)))
                    .font(.system(size: DeviceCompat.isiOS() ? 50 : 130).monospacedDigit().bold())
                    .foregroundStyle(.linearGradient(colors: [.accentColor, .accentColor.opacity(0.5)],
                                                     startPoint: .topLeading, endPoint: .trailing))
            } else {
                AnimatedGroupNumberView(number: index, transcation: Transaction(animation: animationType.getAnimation(duration)))
                    .font(.system(size: DeviceCompat.isiOS() ? 50 : 130).monospacedDigit().bold())
                    .foregroundColor(.accentColor)
            }
            
            ScrollView {
                VStack {
                    Picker(selection: $animationType) {
                        ForEach(AnimationType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    } label: {
                        Text("Animation")
                    }
                    .fixedSize()
                    
                    if animationType != .defaultAnimation && animationType != .spring {
                        Picker(selection: $duration) {
                            ForEach([0.3, 0.5, 1.0, 2.0], id: \.self) { number in
                                Text(String(number))
                                    .tag(number)
                            }
                        } label: {
                            Text("Duration (Seconds)")
                        }
                        .fixedSize()
                    }
                }.padding()
                
                Text("Input [0-1000,000]")
                
                HStack {
                    TextField("Input", text: $indexString)
#if !os(tvOS)
                        .textFieldStyle(.roundedBorder)
#endif
                        .frame(minWidth: 200)
                        .fixedSize()
                        .onChange(of: index) { newValue in
                            indexString = String(newValue)
                        }
                    Button("Submit") {
                        index = (Int(indexString) ?? 0).clamp(to: 0...1000000)
                    }
                }.padding()
                
                HStack {
                    Button("Increase") {
                        index = (index + 1).clamp(to: 0...1000000)
                    }
                    Button("Decrease") {
                        index = (index - 1).clamp(to: 0...1000000)
                    }
                }
            }
        }
        .navigationTitle("Animated Number")
    }
}
