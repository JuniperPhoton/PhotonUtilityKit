//
//  File.swift
//  
//
//  Created by Photon Juniper on 2022/12/7.
//

import Foundation
import SwiftUI

extension ScenePhase: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .active: return "active"
        case .background: return "background"
        case .inactive: return "inactive"
        @unknown default:
            return "unknown default"
        }
    }
}
