//
//  CryptoViewModelTests.swift
//  CryptoCoinsTests
//
//  Created by Harshal Wani on 03/12/24.
//

import XCTest
import Quick
import Nimble
import Combine
@testable import harshal_wani_task

final class MockCryptoDataProvider: CryptoDataProviding {
    var coins: [CryptoItem] = []
    var coinsPublisher: AnyPublisher<[CryptoItem], Never> {
        Just(coins)
            .eraseToAnyPublisher()
    }
    
    func fetchData() async throws {
        // Simulate an API delay
      try await Task.sleep(nanoseconds: 300_000_000)
    }
}

class CryptoViewModelTests: QuickSpec {
  override class func spec() {
    
    
    describe("CryptoViewModel") {
      
      var viewModel: CryptoViewModel!
      var mockDataProvider: MockCryptoDataProvider!
      var cancellables: Set<AnyCancellable>!
      var  mockCoins: [CryptoItem]!
      
      beforeEach {
        mockDataProvider = MockCryptoDataProvider()
        viewModel = CryptoViewModel(dataProvider: mockDataProvider)
        cancellables = []
        
        let bundle = Bundle(for: self)
        guard let path = bundle.path(forResource: "SampleData", ofType: "json") else {
          fail("Unable to find SampleData.json")
          throw NSError(domain: "Unable to find SampleData.json", code: 2, userInfo: nil)
        }
        let fileURL = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: fileURL)
        mockCoins = try JSONDecoder().decode([CryptoItem].self, from: data)
        mockDataProvider.coins = mockCoins

      }
      
      context("When initialized") {
        
        it("1. should have loading state initially") {
          expect(viewModel.dataState).to(equal(.loading))
        }
        
        it("2. should fetch and bind data correctly") {
                    
          expect(viewModel.dataState).to(equal(.loading))
          
          // Trigger the fetch
          viewModel.fetchAndInitializeData()
          
          
          // Expect the coinsPublisher to emit the correct items
          viewModel.coinsPublisher
            .sink { coins in
              expect(coins.count).to(equal(2))
              expect(coins[0].name).to(equal("Bitcoin"))
              expect(coins[1].name).to(equal("Ethereum"))
            }
            .store(in: &cancellables)
        }
      }
      
      context("when searching for a coin") {
        beforeEach {
          viewModel.fetchAndInitializeData()
        }
        
        it("3. should filter coins by search phrase") {
          viewModel.search(for: "Bit")
          viewModel.coinsPublisher
            .sink { coins in
              expect(coins.count).to(equal(1))
              expect(coins[0].name).to(equal("Bitcoin"))
            }
            .store(in: &cancellables)
        }
        
        it("3. should reset to all coins when search is cleared") {
          viewModel.search(for: "")
          viewModel.coinsPublisher
            .sink { coins in
              expect(coins.count).to(equal(2))
            }
            .store(in: &cancellables)
        }
      }
      
      context("when applying filters") {
        beforeEach {
          viewModel.fetchAndInitializeData()
        }
        
        it("4. should filter coins correctly based on the filter set") {
          viewModel.filterCoins(with: "Coin", action: .add, searchPhrase: "")
          
          viewModel.coinsPublisher
            .sink { coins in
              // Mock filter logic: Assume "Popular" filters out "Ethereum"
              expect(coins.count).to(equal(1))
              expect(coins[0].name).to(equal("Bitcoin"))
            }
            .store(in: &cancellables)
        }
      }
    }
  }
}
