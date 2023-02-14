//
//  TextExtractor.swift
//  MyerList
//
//  Created by Photon Juniper on 2022/12/28.
//

import Foundation
import Vision

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public class TextExtractor {
    public static let shared = TextExtractor()
    
    enum ExtractError: Error {
        case imageError
        case recognizationError
    }
    
    private init() {
        // empty
    }
    
    public func extractFromImage(cgImage: CGImage?) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            guard let cgImage = cgImage else {
                continuation.resume(throwing: ExtractError.imageError)
                return
            }
            
            // Create a new image-request handler.
            let requestHandler = VNImageRequestHandler(cgImage: cgImage)
            
            // Create a new request to recognize text.
            let request = VNRecognizeTextRequest(completionHandler: { request, e in
                guard let observations =
                        request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ExtractError.recognizationError)
                    return
                }
                
                let recognizedStrings = observations.compactMap { observation in
                    // Return the string of the top VNRecognizedText instance.
                    return observation.topCandidates(1).first?.string ?? "" + "\n"
                }
                
                let result = recognizedStrings.joined()
                print("recognizedStrings are \(recognizedStrings.joined(separator: "\n"))")
                continuation.resume(returning: result)
            })
            
            if #available(iOS 16.0, macOS 13.0, *) {
                request.automaticallyDetectsLanguage = true
            } else {
                request.recognitionLanguages = ["zh-cn", "en-us"]
            }
            
            do {
                // Perform the text-recognition request.
                try requestHandler.perform([request])
            } catch {
                print("Unable to perform the requests: \(error).")
                continuation.resume(returning: "")
            }
        }
    }
}
