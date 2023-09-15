//
//  File.swift
//
//
//  Created by Photon Juniper on 2023/9/15.
//

import Foundation

#if canImport(UIKit) && os(iOS)
import UIKit

private protocol UIImageReaderProtocol {
    func uiImage(data: Data?) -> UIImage?
}

/// Provides a compat way to decode image using high dynamic range.
public class UIImageReaderCompat: UIImageReaderProtocol {
    public let useDynamicRange: Bool
    
    /// Construct ``UIImageReaderCompat`` specifying ``useDynamicRange`` config.
    /// Note that ``useDynamicRange`` supports on iOS 17.0 or above.
    public init(useDynamicRange: Bool) {
        self.useDynamicRange = useDynamicRange
    }
    
    public func uiImage(data: Data?) -> UIImage? {
        if #available(iOS 17, *), useDynamicRange {
            return UIImageReaderWrapper().uiImage(data: data)
        } else {
            return UIImageReaderStub().uiImage(data: data)
        }
    }
}

@available(iOS 17.0, *)
private class UIImageReaderWrapper: UIImageReaderProtocol {
    // Set up a common reader for all UIImage read requests.
    private static let reader: UIImageReader = {
        var config = UIImageReader.Configuration()
        config.prefersHighDynamicRange = true
        return UIImageReader(configuration: config)
    }()
    
    func uiImage(data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImageReaderWrapper.reader.image(data: data)
    }
}

private class UIImageReaderStub: UIImageReaderProtocol {
    func uiImage(data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}
#endif
