//
//  CryptoViewModel.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 01/12/24.
//

import Foundation
import Combine

// MARK: ChatSelectionState


protocol CryptoListState {
  var dataStatePublisher: AnyPublisher<DataState, Never> { get }
  var coinsPublisher: AnyPublisher<[CryptoItem], Never> { get }
  var filterTagsPublisher: AnyPublisher<[String], Never> { get }
}

protocol CryptoListListener {
  var coinsPublisher: AnyPublisher<[CryptoItem], Never> { get }
  func search(for searchPhrase: String)
  func filterCoins(with filter: String, action: FilterAction, searchPhrase: String)
  func resetResult()
}

final class CryptoViewModel: CryptoListListener, CryptoListState {
  
  // MARK: - Dependencies
  private let dataProvider: CryptoDataProviding
  
  // MARK: - Internal State
  private var cryptoCoins: [CryptoItem] = []
  private var filterSet: [CryptoFilterSet] = []
  
  @Published private var filteredCoins: [CryptoItem] = []
  @Published private(set) var dataState: DataState = .loading
  
  // MARK: - Combine Publishers
  var dataStatePublisher: AnyPublisher<DataState, Never> {
    $dataState.eraseToAnyPublisher()
  }
  
  var coinsPublisher: AnyPublisher<[CryptoItem], Never> {
    $filteredCoins
      .dropFirst()
      .removeDuplicates()
      .eraseToAnyPublisher()
  }
  
  var filterTagsPublisher: AnyPublisher<[String], Never> {
    Just(CryptoFilterSet.allCases.map { $0.text })
      .eraseToAnyPublisher()
  }
  
  private var cancellables: Set<AnyCancellable> = []
  
  // MARK: - Initialization
  init(dataProvider: CryptoDataProviding) {
    self.dataProvider = dataProvider
    fetchAndInitializeData()
  }
  
  // MARK: - Data Fetching
   func fetchAndInitializeData() {
    dataState = .loading
    Task {
      do {
        try await dataProvider.fetchData()
        dataState = .success
        bindCoinsPublisher()
      } catch {
        dataState = .error(error.localizedDescription)
      }
    }
  }
  
  private func bindCoinsPublisher() {
    dataProvider.coinsPublisher
      .sink { [weak self] coins in
        self?.cryptoCoins = coins
        self?.filteredCoins = coins
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Public Methods
  func search(for searchPhrase: String) {
    filteredCoins = searchPhrase.isEmpty ? cryptoCoins : filterCoinsBySearchPhrase(searchPhrase)
  }
  
  func filterCoins(with filter: String, action: FilterAction, searchPhrase: String) {
    updateFilterSet(filter, action: action)
    applyFilters(searchPhrase: searchPhrase)
  }
  
  func resetResult() {
    filteredCoins = cryptoCoins
  }
  
  // MARK: - Private Methods
  private func filterCoinsBySearchPhrase(_ searchPhrase: String) -> [CryptoItem] {
    cryptoCoins.filter { $0.name.range(of: searchPhrase, options: .caseInsensitive) != nil }
  }
  
  private func updateFilterSet(_ filter: String, action: FilterAction) {
      if let filterItem = CryptoFilterSet.allCases.first(where: { $0.text == filter }) {
          switch action {
          case .add:
              if !filterSet.contains(filterItem) {
                  filterSet.append(filterItem)
              }
          case .remove:
              filterSet.removeAll { $0 == filterItem }
          }
      }
  }

  
  private func applyFilters(searchPhrase: String) {
    let filteredBySearch = searchPhrase.isEmpty ? cryptoCoins : filterCoinsBySearchPhrase(searchPhrase)
    
    filteredCoins = filteredBySearch.filter { coin in
      filterSet.allSatisfy { $0.matches(item: coin) }
    }
  }
}
