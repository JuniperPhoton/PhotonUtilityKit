//
//  File.swift
//  
//
//  Created by Photon Juniper on 2022/12/11.
//

import Foundation

public extension String? {
    var notEmptySelf: String? {
        guard let self = self else {
            return nil
        }
        
        if self.isEmpty {
            return nil
        }
        
        return self
    }
    
    func isNotNullNorEmpty() -> Bool {
        return self != nil && self?.isEmpty == false
    }
}

public extension String {
    /// Get a localized string.
    func localized(withComment: String = "") -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
}

public extension Comparable {
    /// Clamp this to the closed ``range``.
    func clamp(to range: ClosedRange<Self>) -> Self {
        if self < range.lowerBound {
            return range.lowerBound
        }
        if self > range.upperBound {
            return range.upperBound
        }
        return self
    }
    
    /// Clamp this to the  half-open ``range``.
    func clamp(to range: Range<Self>) -> Self {
        if self < range.lowerBound {
            return range.lowerBound
        }
        if self >= range.upperBound {
            return range.upperBound
        }
        return self
    }
}
