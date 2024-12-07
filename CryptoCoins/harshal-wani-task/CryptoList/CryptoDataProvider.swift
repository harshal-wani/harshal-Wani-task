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
  private let localStorageKey = "cryptoCoins"
  private let dataStorageManager: DataStorageProvinding

  // MARK: - Initializer
  
  init(apiService: APIServiceProtocol, dataStorageManager: DataStorageProvinding = UserDefaultsManager()) {
    self.apiService = apiService
    self.dataStorageManager = dataStorageManager
  }
  
  // MARK: - Public Methods
  
  func fetchData() async throws {
    do {
      let coins = try await apiService.fetch([CryptoItem].self, .getCryptoList())
      self.cryptoCoins = coins
      saveOfflineData(coins)
    } catch {
      loadOfflineData()
      throw error
    }
  }
  
  // MARK: - Offline Data Handling
    
  private func saveOfflineData(_ coins: [CryptoItem]) {
    self.dataStorageManager.store(coins, forKey: localStorageKey)
  }
  
  private func loadOfflineData() {
    guard let data: [CryptoItem] = self.dataStorageManager.retrive([CryptoItem].self, key: localStorageKey) else { return }
    self.cryptoCoins = data

  }
}

