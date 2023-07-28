//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/7/28.
//

import SwiftUI
import PhotonUtility

/// A view to display a ``number`` in the range of [0, 1000,000].
/// When the ``number`` changes, animations will be used to change each digit of this number.
public struct AnimatedGroupNumberView: View {
    public let number: Int
    public let transcation: Transaction
    
    @State private var numbers: [NumberItem] = []
    
    /// Initialzie the ``AnimatedGroupNumberView`` with:
    /// - parameter number: The number to be displayed.
    /// - parameter transcation: The ``Transaction`` to be applied when animating.
    public init(number: Int, transcation: Transaction) {
        self.number = number
        self.transcation = transcation
    }
    
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            HStack(spacing: 0) {
                ForEach(numbers, id: \.id) { i in
                    AnimatedNumberView(numberItem: i, transcation: transcation)
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity).animation(.easeOut.speed(i.speed)),
                                                removal: .scale))
                }
            }
        }
        .onChange(of: number) { newValue in
            updateNumbers(number: newValue)
        }.onAppear {
            updateNumbers(number: number)
        }
    }
    
    private func updateNumbers(number: Int) {
        var page = number
        
        let million = page / 1000000
        page -= million * 1000000
        
        let hundredThousand = page / 100000
        page -= hundredThousand * 100000
        
        let tenThousand = page / 10000
        page -= tenThousand * 10000
        
        let thousand = page / 1000
        page -= thousand * 1000
        
        let hundred = page / 100
        page -= hundred * 100
        
        let tens = page / 10
        page -= tens * 10
        
        let ones = page
        
        withDefaultAnimation {
            let numbers = [
                NumberItem(id: "million", number: million, speed: 0.47),
                NumberItem(id: "hundredThousand", number: hundredThousand, speed: 0.48),
                NumberItem(id: "tenThousand", number: tenThousand, speed: 0.49),
                NumberItem(id: "thousand", number: thousand, speed: 0.5),
                NumberItem(id: "hundard", number: hundred, speed: 0.6),
                NumberItem(id: "tens", number: tens, speed: 0.7),
                NumberItem(id: "ones", number: ones, speed: 1.0)
            ]
            
            if let first = numbers.firstIndex(where: { $0.number != 0 }) {
                self.numbers = numbers.suffix(numbers.count - first)
            } else {
                self.numbers = []
            }
        }
    }
}

/// A struct representing a number from [0-9].
fileprivate struct NumberItem {
    public let id: String
    public let number: Int
    public let speed: Double
    
    public init(id: String, number: Int, speed: Double) {
        self.id = id
        self.number = number
        self.speed = speed
    }
}

fileprivate struct AnimatedNumberView: View {
    let numberItem: NumberItem
    let transcation: Transaction
    
    @StateObject private var stateHolder = NumberStateHolder()
    
    public init(numberItem: NumberItem, transcation: Transaction) {
        self.numberItem = numberItem
        self.transcation = transcation
    }
    
    public var body: some View {
        ZStack {
            Text("\(stateHolder.oldNumber)")
                .offset(y: stateHolder.oldNumberOffsetY)
            
            Text("\(stateHolder.newNumber)")
                .offset(y: stateHolder.newNumberOffsetY)
        }.clipped()
            .transaction { $0.animation = $0.animation?.speed(numberItem.speed) }
            .listenHeightChanged { height in
                stateHolder.fontHeight = height
                stateHolder.oldNumberOffsetY = height
                stateHolder.newNumberOffsetY = 0
            }
            .onChange(of: numberItem.number) { newValue in
                stateHolder.oldNumber = stateHolder.newNumber
                
                if stateHolder.oldNumber == 0 && newValue == 9 {
                    stateHolder.increased = false
                } else if stateHolder.oldNumber == 9 && newValue == 0 {
                    stateHolder.increased = true
                } else {
                    stateHolder.increased = newValue > stateHolder.oldNumber
                }
                
                if stateHolder.increased {
                    stateHolder.newNumberOffsetY = -stateHolder.fontHeight
                    stateHolder.oldNumberOffsetY = 0
                } else {
                    stateHolder.newNumberOffsetY = stateHolder.fontHeight
                    stateHolder.oldNumberOffsetY = 0
                }
                
                stateHolder.newNumber = newValue
                
                print("AnimatedNumberView state holder \(String(reflecting: stateHolder))")
                
                withTransaction(transcation) {
                    if stateHolder.increased {
                        stateHolder.newNumberOffsetY = 0
                        stateHolder.oldNumberOffsetY = stateHolder.fontHeight
                    } else {
                        stateHolder.newNumberOffsetY = 0
                        stateHolder.oldNumberOffsetY = -stateHolder.fontHeight
                    }
                }
            }
            .onAppear {
                stateHolder.oldNumber = numberItem.number
                stateHolder.newNumber = numberItem.number
            }
    }
}

fileprivate class NumberStateHolder: ObservableObject, CustomDebugStringConvertible {
    var increased = false
    
    @Published var oldNumber = 0
    @Published var newNumber = 0
    
    @Published var newNumberOffsetY: CGFloat = 0
    @Published var oldNumberOffsetY: CGFloat = 100
    
    var fontHeight: CGFloat = 100
    
    var debugDescription: String {
        "increased: \(increased), \(oldNumber) -> \(newNumber), old y: \(oldNumberOffsetY), new y: \(newNumberOffsetY)"
    }
}
