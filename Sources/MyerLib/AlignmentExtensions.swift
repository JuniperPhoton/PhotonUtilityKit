//
//  AlignmentExtensions.swift
//  MyerTidy
//
//  Created by Photon Juniper on 2022/9/24.
//

import Foundation
import SwiftUI

extension HorizontalAlignment {
    private struct CustomHorizontalAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[HorizontalAlignment.center]
        }
    }
    
    static let customHorizontalAlignment = HorizontalAlignment(
        CustomHorizontalAlignment.self
    )
}

extension VerticalAlignment {
    private struct CustomVerticalAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            // Default to bottom alignment if no guides are set.
            context[VerticalAlignment.center]
        }
    }
    
    static let customVerticalAlignment = VerticalAlignment(
        CustomVerticalAlignment.self
    )
}
