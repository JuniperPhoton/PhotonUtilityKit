//
//  IndicatorView.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/2/12.
//

import SwiftUI
import PhotonUtility

public struct IndicatorView: View {
    let selectedIndex: Binding<Int>
    let count: Int
    let foregroundColor: Color
    let tappable: Bool
    
    private let size: CGFloat = DeviceCompat.isTV() ? 30 : 10
    
    public init(selectedIndex: Binding<Int>, count: Int, foregroundColor: Color, tappable: Bool = true) {
        self.selectedIndex = selectedIndex
        self.count = count
        self.foregroundColor = foregroundColor
        self.tappable = tappable
    }
    
    public var body: some View {
        HStack {
            ForEach(0..<count, id: \.self) { page in
                Circle().strokeBorder(foregroundColor, lineWidth: 2)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle().fill(selectedIndex.wrappedValue == page ? foregroundColor : Color.clear)
                    )
                    .contentShape(Circle())
                    .runIf(condition: tappable) { v in
                        v.onTapGestureCompact {
                            withDefaultAnimation {
                                selectedIndex.wrappedValue = page
                            }
                        }
                    }
            }
        }.padding(.vertical, 8)
    }
}

struct IndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorView(selectedIndex: .constant(1), count: 3, foregroundColor: .accentColor)
    }
}
