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
  func search(for searchPhrase: String)
  func filterCoins(with filter: String, action: FilterAction, searchPhrase: String)
  func resetResult()
  func didTapOnCoin(_ cryptoItem: CryptoItem)
}

protocol CryptoRouteable {
  func routeToDetail(for cryptoItem: CryptoItem)
}

final class CryptoViewModel: CryptoListListener, CryptoListState {
  
  // MARK: - Dependencies
  private let dataProvider: CryptoDataProviding
  private let router: CryptoRouteable
  
  // MARK: - Internal State
  private var cryptoCoins: [CryptoItem] = []
  private var filterSet: [CryptoFilterSet] = []
  
  @Published private var filteredCoins: [CryptoItem] = []
  @Published private(set) var dataState: DataState = .loading
  @Published var searchPhrase: String = ""

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
  init(dataProvider: CryptoDataProviding, router: CryptoRouteable) {
    self.dataProvider = dataProvider
    self.router = router
    fetchAndInitializeData()
    bindCoinsPublisher()
    bindSearchPhrasePublisher()
  }
  
  // MARK: - Data Fetching
   func fetchAndInitializeData() {
    dataState = .loading
    Task {
      do {
        try await dataProvider.fetchData()
        dataState = .success
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
  
  private func bindSearchPhrasePublisher() {
    $searchPhrase
      .dropFirst()
      .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
      .sink { [weak self] text in
        self?.applyFilters(searchPhrase: text)
      }
      .store(in: &cancellables)
  }
  

  // MARK: - Public Methods
  func search(for searchPhrase: String) {
    self.searchPhrase = searchPhrase
  }
  
  func filterCoins(with filter: String, action: FilterAction, searchPhrase: String) {
    updateFilterSet(filter, action: action)
    applyFilters(searchPhrase: searchPhrase)
  }
  
  func resetResult() {
    filteredCoins = cryptoCoins
  }
  
  func didTapOnCoin(_ cryptoItem: CryptoItem) {
    router.routeToDetail(for: cryptoItem)
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
