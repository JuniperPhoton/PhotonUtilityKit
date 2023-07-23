//
//  HighliableCodeView.swift
//  PhotonUtilityKitDemo
//
//  Created by Photon Juniper on 2023/6/24.
//

import SwiftUI
import PhotonUtility
import PhotonUtilityView

#if canImport(Highlightr)
import Highlightr
#endif

#if canImport(Highlightr)
func getHighlightr(darkMode: Bool) -> Highlightr? {
    guard let highlightr = Highlightr() else {
        return nilHighlightr
    }
    highlightr.setTheme(to: darkMode ? "vs 2015" : "xcode")
    return highlightr
}
#endif

class HighliableCode: ObservableObject {
    let code: String
    
    @Published var highlighted: NSAttributedString = .init()
    
    init(code: String) {
        self.code = code
    }
    
    @MainActor
    func resolve(darkMode: Bool) async {
#if canImport(Highlightr)
        highlighted = getHighlightr(darkMode: darkMode)?.highlight(code, as: "swift") ?? .init()
#else
        highlighted = NSAttributedString(string: code)
#endif
    }
}

struct HighliableCodeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var code: HighliableCode
    
    var body: some View {
#if canImport(Highlightr)
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
#else
        Text("Not supported")
#endif
    }
}
