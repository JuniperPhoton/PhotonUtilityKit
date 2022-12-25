//
//  AppAnimation.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/18.
//

import Foundation
import SwiftUI

public func withEastOutAnimation<Result>(_ delay: Double = 0.0, _ body: () throws -> Result) -> Result? {
    return try? withAnimation(Animation.easeOut.delay(delay)) {
        try body()
    }
}
