//
//  CryptoModel.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 01/12/24.
//

import UIKit

struct CryptoItem: Codable, Hashable {
  let name: String
  let symbol: String
  let isNew: Bool
  let isActive: Bool
  let type: CryptoType
  
  enum CodingKeys: String, CodingKey {
    case name
    case symbol
    case isNew = "is_new"
    case isActive = "is_active"
    case type
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try container.decode(String.self, forKey: .name)
    self.symbol = try container.decode(String.self, forKey: .symbol)
    self.isNew = try container.decode(Bool.self, forKey: .isNew)
    self.isActive = try container.decode(Bool.self, forKey: .isActive)
    self.type = try container.decode(CryptoType.self, forKey: .type)
  }
}
