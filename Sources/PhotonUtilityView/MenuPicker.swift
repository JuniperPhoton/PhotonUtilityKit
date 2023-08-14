//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/8/10.
//

import SwiftUI

#if os(iOS) || os(macOS)
@available(iOS 15.0, macOS 12.0, *)
public extension MenuPicker {
    init(selection: Binding<Selection>,
         selections: [Selection]) where LabelView == EmptyView, FooterView == EmptyView {
        self.init(selection: selection, selections: selections) {
            EmptyView()
        } footerView: {
            EmptyView()
        }
    }
    
    init(selection: Binding<Selection>,
         selections: [Selection],
         labelView: @escaping () -> LabelView) where FooterView == EmptyView {
        self.init(selection: selection, selections: selections) {
            labelView()
        } footerView: {
            EmptyView()
        }
    }
    
    init(selection: Binding<Selection>,
         selections: [Selection],
         footerView: @escaping () -> FooterView) where LabelView == EmptyView {
        self.init(selection: selection, selections: selections) {
            EmptyView()
        } footerView: {
            footerView()
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
public struct MenuPicker<Selection: Identifiable & Hashable & Localizable, LabelView: View, FooterView: View>: View {
    let selection: Binding<Selection>
    let selections: [Selection]
    
    let labelView: () -> LabelView
    let footerView: () -> FooterView
    
    init(selection: Binding<Selection>,
         selections: [Selection],
         labelView: @escaping () -> LabelView,
         footerView: @escaping () -> FooterView ) {
        self.selection = selection
        self.selections = selections
        self.labelView = labelView
        self.footerView = footerView
    }
    
    public var body: some View {
        Menu {
            ForEach(selections, id: \.self) { s in
                HStack {
                    Text(s.localizedStringKey)
                    Image(systemName: selection.wrappedValue == s ? "checkmark" : "")
                }.asButton {
                    withTransaction(selection.transaction) {
                        selection.wrappedValue = s
                    }
                }
            }
            
            let footerView = footerView()
            if type(of: footerView) == EmptyView.self {
                EmptyView()
            } else {
                Divider()
                footerView
            }
        } label: {
            let label = labelView()
            if type(of: label) == EmptyView.self {
                HStack {
                    Text(selection.wrappedValue.localizedStringKey)
                    Image(systemName: "chevron.up.chevron.down")
                }
            } else {
                label
            }
        }
#if os(macOS)
        .menuStyle(.borderedButton)
        .menuIndicator(.hidden)
#endif
        .controlSize(.large)
    }
}
#endif
