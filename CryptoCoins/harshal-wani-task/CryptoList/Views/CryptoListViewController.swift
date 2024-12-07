//
//  CryptoListViewController.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 30/11/24.
//

import Foundation
import UIKit
import SnapKit
import Combine
import TagListView

final class CryptoListViewController: UIViewController {
  
  // MARK: - Type Aliases
  
  typealias DataSource = UITableViewDiffableDataSource<CryptoSection, CryptoItem>
  typealias Snapshot = NSDiffableDataSourceSnapshot<CryptoSection, CryptoItem>
  typealias ViewModel = CryptoListState & CryptoListListener
  
  // MARK: - Properties
  
  private(set) var listDataSource: DataSource?
  private var cancellables: Set<AnyCancellable> = []
  
  private let state: CryptoListState
  let listener: CryptoListListener
  
  // MARK: - Initializers
  
  init(state: CryptoListState, listener: CryptoListListener) {
    self.state = state
    self.listener = listener
    super.init(nibName: nil, bundle: nil)
    setupListener()
  }
  
  convenience init(viewModel: ViewModel) {
    self.init(state: viewModel, listener: viewModel)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UI Elements
  
  private lazy var loaderView: UIActivityIndicatorView = {
    let loader = UIActivityIndicatorView(style: .large)
    loader.hidesWhenStopped = true
    return loader
  }()
  
  private(set) lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.delegate = self
    tableView.register(CryptoCoinCell.self, forCellReuseIdentifier: CryptoCoinCell.identifier)
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 100
    return tableView
  }()
  
  private(set) lazy var searchController: UISearchController = {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.placeholder = "Search"
    searchController.hidesNavigationBarDuringPresentation = true
    searchController.searchResultsUpdater = self
    return searchController
  }()
  
  private lazy var tagView: FilterTagView = {
  let tagView = FilterTagView()
    tagView.delegate = self
    return tagView
  }()
  
  private lazy var noRecordsView: UIView = {
    let view = UIView()
    let label = UILabel()
    label.text = "No records found."
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    view.addSubview(label)
    label.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
    return view
  }()
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Crypto Coins"
    setupUI()
    setupSearchBar()
    setupDataSource()
  }
  
  // MARK: - Setup Methods
  
  private func setupUI() {
    view.backgroundColor = .white
    view.addSubview(tagView)
    view.addSubview(tableView)
    view.addSubview(loaderView)
    
    tagView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide)
      make.left.right.equalToSuperview()
    }
    
    tableView.snp.makeConstraints { make in
      make.top.equalTo(tagView.snp.bottom)
      make.left.right.bottom.equalToSuperview()
    }
    
    loaderView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupSearchBar() {
    definesPresentationContext = true
    navigationItem.hidesSearchBarWhenScrolling = false
    navigationItem.searchController = searchController
  }
  
  private func setupDataSource() {
    listDataSource = DataSource(tableView: tableView) { tableView, indexPath, item in
      guard let cell = tableView.dequeueReusableCell(withIdentifier: CryptoCoinCell.identifier, for: indexPath) as? CryptoCoinCell else {
        fatalError("Failed to dequeue CryptoCoinCell")
      }
      cell.style(with: item)
      return cell
    }
  }
  
  private func setupListener() {
    state.dataStatePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        guard let self else { return }
        self.handleDataState(state)
      }
      .store(in: &cancellables)
    
    
    Publishers.CombineLatest(state.coinsPublisher.first(),
                             state.filterTagsPublisher.first())
      .receive(on: DispatchQueue.main)
      .sink { [weak self] coins, tags in
        guard let self else { return }
        let uniqueTags = Array(Set(tags))
                self.tagView.tags = uniqueTags
                self.tagView.isHidden = uniqueTags.isEmpty
      }.store(in: &cancellables)
    
    
    state.coinsPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] coins in
        guard let self else { return }
        self.updateTable(with: coins)
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Update Methods
  
  private func updateTable(with coins: [CryptoItem]) {
    var snapshot = Snapshot()
    snapshot.appendSections([CryptoSection.main])
    snapshot.appendItems(coins)
    listDataSource?.apply(snapshot, animatingDifferences: true)
    updateTableViewBackground(isEmpty: coins.isEmpty)
  }
  
  private func updateTableViewBackground(isEmpty: Bool) {
    tableView.backgroundView = isEmpty ? noRecordsView : nil
  }
  
  // MARK: - Error Handling
  
  private func handleDataState(_ state: DataState) {
    switch state {
    case .loading:
      loaderView.startAnimating()
    case .success:
      loaderView.stopAnimating()
    case .error(let message):
      loaderView.stopAnimating()
      updateTableViewBackground(isEmpty: true)
      showError(message)
    }
  }
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}

