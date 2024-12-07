//
//  UserDefaultsManager.swift
//  harshal-wani-task
//
//  Created by Harshal Wani on 06/12/24.
//

import Foundation

protocol DataStorageProvinding: AnyObject {
  func store<T: Encodable>(_ data: T, forKey key: String)
  func retrive<T: Decodable>(_ type: T.Type, key: String) -> T?
}

final class UserDefaultsManager: DataStorageProvinding {
  
  let userDefaults: UserDefaults
  
  init(userDefaults: UserDefaults = .standard) {
    self.userDefaults = userDefaults
  }
  
  func store<T>(_ data: T, forKey key: String) where T : Encodable {
    guard let model = try? JSONEncoder().encode(data) else { return }
    self.userDefaults.set(model, forKey: key)
  }
  
  func retrive<T>(_ type: T.Type, key: String) -> T? where T : Decodable {
    guard let model = self.userDefaults.data(forKey: key),
          let decoded = try? JSONDecoder().decode(T.self, from: model) else { return nil }
    return decoded
  }
  
}
