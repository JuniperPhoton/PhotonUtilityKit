//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/4/12.
//

import Foundation

/// Get a ``URL`` to send feedback to, with ``subject`` and ``body``.
public func getFeedbackURL(subject: String, body: String) -> URL? {
    var component = URLComponents(string: "mailto:dengweichao@hotmail.com")
    component?.queryItems = [
        URLQueryItem(name: "subject", value: subject),
        URLQueryItem(name: "body", value: body)
    ]
    return component?.url
}
