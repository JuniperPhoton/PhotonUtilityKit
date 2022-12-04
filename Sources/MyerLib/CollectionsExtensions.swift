//
//  Collections+.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/4/5.
//

import Foundation
import SwiftUI

public extension Collection {
    func any(check: (Element) -> Bool) -> Bool {
        for e in self {
            if !check(e) {
                return false
            }
        }
        return true
    }
    
    func countOf(check: (Element) -> Bool) -> Int {
        var count = 0
        forEach { e in
            if (check(e)) {
                count = count + 1
            }
        }
        return count
    }
    
    func forEachIndexed(_ body: ((Element, Int) -> Void)) {
        var index = 0
        forEach { e in
            body(e, index)
            index = index + 1
        }
    }
    
    func filterIndexed(_ isIncluded: ((Element, Int) -> Bool)) -> [Element] {
        var result: [Element] = []
        
        var index = 0
        forEach { e in
            if isIncluded(e, index) {
               result.append(e)
            }
            index = index + 1
        }
        
        return result
    }
    
    func joinToString(sepatator: String = "_",
                      toString: (Element) -> String) -> String {
        var output = ""
        
        forEachIndexed { e, index in
            let elementString = toString(e)
            output = output + elementString
            if index != self.count - 1 {
                output = output + sepatator
            }
        }
        return output
    }
}
