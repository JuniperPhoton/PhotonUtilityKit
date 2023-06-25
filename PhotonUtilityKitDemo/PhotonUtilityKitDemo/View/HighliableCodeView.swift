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
    
    @MainActor
    func resolve(darkMode: Bool) async {
        highlighted = getHighlightr(darkMode: darkMode)?.highlight(code) ?? .init()
    }
}

struct HighliableCodeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var code: HighliableCode
    
    var body: some View {
        ZStack {
            ScrollableTextViewCompat(text: code.highlighted, foregroundColorName: nil, autoScrollToBottom: false)
                .frame(maxHeight: 200)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.1)))
        }
            .onAppear {
                Task {
                    await code.resolve(darkMode: colorScheme == .dark)
                }
            }
            .onChange(of: colorScheme) { newValue in
                Task {
                    await code.resolve(darkMode: newValue == .dark)
                }
            }
    }
}
