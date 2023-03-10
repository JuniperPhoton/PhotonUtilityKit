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
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle().fill(selectedIndex.wrappedValue == page ? foregroundColor : Color.clear)
                    )
                    .contentShape(Circle())
                    .runIf(condition: tappable) { v in
#if !os(tvOS)
                        v.onTapGesture {
                            withEaseOutAnimation {
                                selectedIndex.wrappedValue = page
                            }
                        }
#else
                        v
#endif
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
