//
//  LinksDetector.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/2/1.
//

import Foundation
import MyerLib

public class LinksDetector {
    public static let shared = LinksDetector()
    
    private init() {
        // empty
    }
    
    public func detectLink(content: String) -> URL? {
        return detect(content: content)
    }
    
    private func detect(content: String) -> URL? {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let output = detector.matches(in: content, range: NSRange(location: 0, length: content.count))
        guard let firstURL = output.first(where: { r in
            r.url != nil
        }) else {
            return nil
        }
        
        return firstURL.url
    }
}
