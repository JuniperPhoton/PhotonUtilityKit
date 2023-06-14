//
//  File.swift
//  
//
//  Created by Photon Juniper on 2023/6/14.
//

import Foundation

public struct APIError: Error {
    public let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

/// A wrapper for handling resources for Supabase database.
///
/// You initialize the client passing the baseURL and the table name, and call the ``getResources`` to perform the GET request.
public class PhotonSupabaseClient {
    let baseURL: URL
    let resource: String
    let key: String
    
    private let session: URLSession
    
    /// Initialize the client.
    ///
    /// - parameter baseURL: baseURL of Supabase, including the /rest/v1/ path.
    /// - parameter resource: the resource name of Supabase.
    /// - parameter key: the API key for authorization.
    /// - parameter session: the URLSession to perform URL request, default to .shared
    public init(baseURL: URL, resource: String, key: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.resource = resource
        self.key = key
        self.session = session
    }
    
    /// Get the resources. If fails, it throws an error.
    ///
    /// It returns the models based on your generic type, which should comform to ``Decodable`` protocol.
    ///
    /// - parameter select: columns to be select
    /// - parameter filters: a dictionay containing how the fields are filtered, like `"id":"eq.1"` ,which means id should equals to 1.
    public func getResources<T: Decodable>(select: String = "*",
                                           filters: [String: String]) async throws -> T {
        guard let url = getURL(select: select, filters: filters) else {
            throw APIError("URL failed")
        }
        
        var request = URLRequest(url: url)
        request.setValue(self.key, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(self.key)", forHTTPHeaderField: "Authorization")
        
        let session = self.session
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError("Invalid response")
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } else {
            throw APIError("Request failed with status code: \(httpResponse.statusCode)")
        }
    }
    
    private func getURL(select: String = "*", filters: [String: String]) -> URL? {
        guard var urlComponent = URLComponents(string: baseURL.absoluteString) else {
            return nil
        }
        
        urlComponent.path += resource
        
        let queryItems = filters.map { (k, v) in
            URLQueryItem(name: k, value: v)
        }
        
        urlComponent.queryItems = queryItems
          
        return urlComponent.url
    }
}

