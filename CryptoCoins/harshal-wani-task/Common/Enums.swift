//
//  Enums.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 02/12/24.
//

// MARK: - Data State

enum DataState: Equatable {
  case loading
  case success
  case error(String)
}

// MARK: - Crypto type

enum CryptoType: String, Codable, CaseIterable {
  case coin = "coin"
  case token = "token"
  case unknown
  
  var text: String {
    switch self {
    case .coin: return "Only Coins"
    case .token: return "Only Tokens"
    case .unknown: return "Unknown"
    }
  }
}

// MARK: - TableView section

enum CryptoSection: CaseIterable, Hashable {
    case main
}

// MARK: - Filter set

enum CryptoFilterSet: Equatable {
  case coins(Bool)
  case tokens(Bool)
  case isActive(Bool)
  case isNew(Bool)
  
  var text: String {
    switch self {
    case .coins(_):
      return "Coins"
    case .tokens(_):
      return "Token"
    case .isActive(_):
      return "Active"
    case .isNew(_):
      return "New"
    }
  }
  
  static let allCases: [CryptoFilterSet] = [
    .coins(true),
    .tokens(true),
    isActive(true),
    isNew(true)
  ]
  
  
  func matches(item: CryptoItem) -> Bool {
    switch self {
    case .coins( _):
      return item.type == .coin
    case .tokens( _):
      return item.type == .token
    case .isActive(let value):
      return item.isActive == value
    case .isNew(let value):
      return item.isNew == value
    }
  }
  
}

enum FilterAction {
  case add
  case remove
}
