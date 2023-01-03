//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/1/3.
//

import Foundation

public extension UserDefaults {
    func bool(forKey: String, defaultValue: Bool) -> Bool {
        if self.object(forKey: forKey) == nil {
            return defaultValue
        }
        return self.bool(forKey: forKey)
    }
    
    func string(forKey: String, defaultValue: String) -> String {
        if self.object(forKey: forKey) == nil {
            return defaultValue
        }
        return self.string(forKey: forKey) ?? defaultValue
    }
    
    func stringArray(forKey: String, defaultValue: [String]) -> [String] {
        if self.object(forKey: forKey) == nil {
            return defaultValue
        }
        return self.stringArray(forKey: forKey) ?? defaultValue
    }
}
