//
//  HighliableCodeView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView
import Highlightr

func getHighlightr(darkMode: Bool) -> Highlightr? {
    guard let highlightr = Highlightr() else {
        return nil
    }
    highlightr.setTheme(to: darkMode ? "vs 2015" : "xcode")
    return highlightr
}

class HighliableCode: ObservableObject {
    let code: String
    
    @Published var highlighted: NSAttributedString = .init()
    
    init(code: String) {
        self.code = code
    }
    
    func resolve(darkMode: Bool) {
        highlighted = getHighlightr(darkMode: darkMode)?.highlight(code) ?? .init()
    }
}

struct HighliableCodeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var code: HighliableCode
    
    var body: some View {
        ZStack {
            ScrollableTextViewCompat(text: code.highlighted, autoScrollToBottom: false)
                .frame(maxHeight: 150)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
        }
            .onAppear {
                code.resolve(darkMode: colorScheme == .dark)
            }
            .onChange(of: colorScheme) { newValue in
                code.resolve(darkMode: newValue == .dark)
            }
    }
}
