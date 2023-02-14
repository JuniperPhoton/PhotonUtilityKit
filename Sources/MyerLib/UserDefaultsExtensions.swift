//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/1/3.
//

import Foundation

public extension UserDefaults {
    /// Get the bool value for a specified key, providing a default value if it's not exists.
    func bool(forKey: String, defaultValue: Bool) -> Bool {
        if self.object(forKey: forKey) == nil {
            return defaultValue
        }
        return self.bool(forKey: forKey)
    }
    
    /// Get the string value for a specified key, providing a default value if it's not exists.
    func string(forKey: String, defaultValue: String) -> String {
        if self.object(forKey: forKey) == nil {
            return defaultValue
        }
        return self.string(forKey: forKey) ?? defaultValue
    }
    
    /// Get the string array for a specified key, providing a default value if it's not exists.
    func stringArray(forKey: String, defaultValue: [String]) -> [String] {
        if self.object(forKey: forKey) == nil {
            return defaultValue
        }
        return self.stringArray(forKey: forKey) ?? defaultValue
    }
}
