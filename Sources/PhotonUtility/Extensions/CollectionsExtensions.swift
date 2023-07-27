//
//  Collections+.swift
//  MyerTidy
//
//  Created by juniperphoton on 2022/4/5.
//

import Foundation
import SwiftUI

public extension Collection {
    /// Return true if at least one element in this collection satisfly the condition.
    func any(check: (Element) -> Bool) -> Bool {
        for e in self {
            if check(e) {
               return true
            }
        }
        return false
    }
    
    /// Return true if all of elements in this collection satisfly the condition.
    func all(check: (Element) -> Bool) -> Bool {
        for e in self {
            if !check(e) {
                return false
            }
        }
        return true
    }
    
    /// Return the count of the element satisfly the condition.
    func countOf(check: (Element) -> Bool) -> Int {
        var count = 0
        forEach { e in
            if check(e) {
                count = count + 1
            }
        }
        return count
    }
    
    /// Same as forEach but you can access the index in it.
    func forEachIndexed(_ body: ((Element, Int) -> Void)) {
        var index = 0
        forEach { e in
            body(e, index)
            index = index + 1
        }
    }
    
    /// Same as filter but you can access the index in it.
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
    
    /// Join the element to a string with separator and custom toString.
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

public extension Collection where Element: CustomStringConvertible {
    /// Join the element that conforms to ``CustomStringConvertible`` protocol to a string with separator.
    func joinToString(_ sepatator: String = "_") -> String {
        return joinToString(sepatator: sepatator) { e in
            e.description
        }
    }
}

public extension Collection {
    /// Mapping this collection to another collection which has s grouping key and an array of corresponding items.
    /// This method is used to list with section enabled.
    func groupInto<K: Hashable, T>(getGroupKey: (Element) -> K,
                                   getGroupValue: (K, [Element]) -> T) -> [T] {
        var result:[T] = []
        
        let dictionary = Dictionary(grouping: self) { e in
            getGroupKey(e)
        }
        
        dictionary.forEach { (key, elements) in
            result.append(getGroupValue(key, elements))
        }
        
        return result
    }
}

public extension Array {
    /// Safely get the item of an array given an index.
    /// If the index is invalid, it will return nil instead.
    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
