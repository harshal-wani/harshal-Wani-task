//
//  EndPoint.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 01/12/24.
//


import Foundation

/// API Constants
struct BaseUrl {
    static let scheme = "https"
    static let host = "37656be98b8f42ae8348e4da3ee3193f.api.mockbin.io"
}

/// HTTPMethod type
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public struct EndPoint {
    let method: HTTPMethod
    private let path: String
    private(set) var queryItem: [String: Any]?
    private(set) var data: Data?

    /// GET request
     init(method: HTTPMethod, path: String, queryItem: [String: Any] = [:]) {
        self.method = method
        self.path = path
        self.queryItem = queryItem
    }

    /// POST request
     init(method: HTTPMethod, path: String, data: Data) {
        self.method = method
        self.path = path
        self.data = data
    }

}

extension EndPoint {
    var url: URL? {
        var components = URLComponents()
        components.scheme = BaseUrl.scheme
        components.host = BaseUrl.host
        components.path = path
        if queryItem?.isEmpty == false {
            components.setQueryItems(with: queryItem!)
        }
        return components.url
    }
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: Any]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
}
