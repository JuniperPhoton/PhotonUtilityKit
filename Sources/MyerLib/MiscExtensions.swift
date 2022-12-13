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
