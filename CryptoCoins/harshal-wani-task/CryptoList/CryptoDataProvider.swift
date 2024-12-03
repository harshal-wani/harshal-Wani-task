//
//  CryptoDataProvider.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 01/12/24.
//
import Foundation
import Combine

// MARK: - API EndPoint

extension EndPoint {
  
  static func getCryptoList() -> EndPoint {
    return EndPoint(method: .get, path: "")
  }
}

// MARK: - CryptoDataProviding protocol

protocol CryptoDataProviding {
  var coinsPublisher: AnyPublisher<[CryptoItem], Never> { get }
  func fetchData() async throws
}

final class CryptoDataProvider: CryptoDataProviding {
  
  // MARK: - Properties
  
  @Published private var cryptoCoins: [CryptoItem] = []
  
  var coinsPublisher: AnyPublisher<[CryptoItem], Never> {
    $cryptoCoins.eraseToAnyPublisher()
  }
  
  private let apiService: APIServiceProtocol
  
  // MARK: - Initializer
  
  /// Initializes the data provider with the given API service.
  /// - Parameter apiService: The service responsible for fetching data from the API.
  init(apiService: APIServiceProtocol) {
    self.apiService = apiService
  }
  
  // MARK: - Public Methods
  
  func fetchData() async throws {
    do {
      let coins = try await apiService.fetch([CryptoItem].self, .getCryptoList())
      self.cryptoCoins = coins
    } catch {
      throw error
    }
  }
}

