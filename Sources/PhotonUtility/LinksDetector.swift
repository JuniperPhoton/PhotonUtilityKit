//
//  LinksDetector.swift
//  MyerList
//
//  Created by Photon Juniper on 2023/2/1.
//

import Foundation

public class LinksDetector {
    public static let shared = LinksDetector()
    
    private init() {
        // empty
    }
    
    public func detectURLScheme(content: String) -> URL? {
        let pattern = "^(.*):\\/\\/(.*)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            let urlString = results.map {
                String(content[Range($0.range, in: content)!])
            }.first
            if let urlString = urlString {
                return URL(string: urlString)
            }
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
        }
        
        return nil
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
