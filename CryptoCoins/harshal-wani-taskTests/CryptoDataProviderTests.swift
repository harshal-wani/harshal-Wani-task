//
//  CryptoDataProviderTests.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 03/12/24.
//

import XCTest
import Quick
import Nimble
import Combine
@testable import harshal_wani_task

class CryptoDataProviderSpec: QuickSpec {
  override class func spec() {
    var cryptoDataProvider: CryptoDataProvider!
    var mockAPIService: MockAPIService!
    var cancellables: Set<AnyCancellable>!
    beforeEach {
      // Create a new mock API service for each test
      mockAPIService = MockAPIService()
      cryptoDataProvider = CryptoDataProvider(apiService: mockAPIService)
      cancellables = []
    }
    
    describe("CryptoDataProvider") {
      
      context("when fetchData is called successfully") {
        
        it("1. should update the coinsPublisher with the fetched data") {
          // Simulate a successful fetch
          mockAPIService.shouldReturnError = false
          
          // Use async/await to wait for the data fetch
          waitUntil { done in
            Task {
              do {
                try await cryptoDataProvider.fetchData()
                // Wait for the publisher to update
                cryptoDataProvider.coinsPublisher
                  .sink { coins in
                    expect(coins).to(haveCount(1))
                    expect(coins.first?.name).to(equal("Monero"))
                    done()
                  }
                  .store(in: &cancellables)
              } catch {
                fail("Failed to fetch data")
              }
            }
          }
        }
      }
      
      context("when fetchData fails") {
        
        it("2. should throw an error") {
          // Simulate an error during fetch
          mockAPIService.shouldReturnError = true
          
          waitUntil { done in
            Task {
              do {
                try await cryptoDataProvider.fetchData()
                fail("Fetch should have failed")
              } catch {
                expect(error).toNot(beNil())
                done()
              }
            }
          }
        }
      }
    }
  }
}



class MockAPIService: APIServiceProtocol {
  var shouldReturnError = false
  
  func fetch<T: Decodable>(_ type: T.Type, _ endpoint: EndPoint) async throws -> T {
    if shouldReturnError {
      throw NSError(domain: "TestError", code: 1, userInfo: nil)
    }
    
    do {
      let jsonData = Data("""
      {
          "name": "Monero",
          "symbol": "XMR",
          "is_new": false,
          "is_active": true,
          "type": "coin"
        }
      """.utf8)
      let mockCoins: CryptoItem = try JSONDecoder().decode(CryptoItem.self, from: jsonData)
      return [mockCoins] as! T
      
    } catch {
      throw error
    }
  }
}
