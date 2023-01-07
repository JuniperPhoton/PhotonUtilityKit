//
//  SwiftUIView.swift
//  
//
//  Created by Photon Juniper on 2023/1/7.
//

import SwiftUI

/// SwiftUI will add the chevron.up.chevron.down to a picker control until iOS 16.
/// Without the image, the picker is hard to be noticed that its clickable.
///
/// This view wrap the ``content`` to a HStack which has a trailing Image displaying a symbol.
@available(iOS 15.0, *)
public struct PickerCompatView<Content: View>: View {
    let content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        HStack {
            content()
            
            if #available(iOS 16.0, *) {
                EmptyView()
            } else {
                Image(systemName: "chevron.up.chevron.down")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
            }
        }
    }
}
