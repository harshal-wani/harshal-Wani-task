//
//  APIService.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 01/12/24.
//


import Foundation

protocol APIServiceProtocol {
  func fetch<T: Codable>(_ type: T.Type, _ endPoint: EndPoint) async throws -> T
}

final class APIService: APIServiceProtocol {
  
  static let shared = APIService()

  func fetch<T: Codable>(_ type: T.Type, _ endPoint: EndPoint) async throws -> T {
    
    guard let url = endPoint.url else {
      throw APIError.invalidURL
    }
    
    /// Check is internet available
    if !Utilities.isInternetAvailable() {
      throw APIError.noNetwork
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = endPoint.method.rawValue
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    if let data = endPoint.data {
      request.httpBody = data
    }
    
    /// Use URLSession to fetch the data asynchronously.
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let statusCode = (response as? HTTPURLResponse)?.statusCode, 200..<299 ~= statusCode else {
      throw APIError.checkErrorCode((response as? HTTPURLResponse)!.statusCode)
    }
    
    let decode =  try self.decodeData(type, data)
    return decode    
  }
  
  /// Generic decode data into model
  /// - Parameter data: Data to parse in model
  private func decodeData<T: Codable>(_ type: T.Type, _ data: Data) throws -> T {
    
    do {
      return try JSONDecoder().decode(T.self, from: data)
    } catch let error {
      guard let err = error as? DecodingError else {
        throw APIError.unknownError
      }
      throw APIError.parseDecodingError(err)
    }
  }
}
