//
//  IndicatorView.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/2/12.
//

import SwiftUI
import MyerLib

public struct IndicatorView: View {
    let selectedIndex: Binding<Int>
    let count: Int
    let foregroundColor: Color
    
    public init(selectedIndex: Binding<Int>, count: Int, foregroundColor: Color) {
        self.selectedIndex = selectedIndex
        self.count = count
        self.foregroundColor = foregroundColor
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
                    .onTapGesture {
                        withEastOutAnimation {
                            selectedIndex.wrappedValue = page
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
