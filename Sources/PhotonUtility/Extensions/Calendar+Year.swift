//
//  Calendar+Year.swift
//  PhotonCamSharedUtils
//
//  Created by JuniperPhoton on 2025/1/11.
//
import Foundation

public extension Calendar {
    /// The last two digits of the current year.
    var yearLastTwoDigits: String {
        let year = self.component(.year, from: Date())
        return String(year % 100)
    }
}
