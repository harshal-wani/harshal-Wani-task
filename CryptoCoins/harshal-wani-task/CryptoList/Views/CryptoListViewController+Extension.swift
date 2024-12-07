//
//  CryptoListViewController+Extension.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 02/12/24.
//

// MARK: - UITableView Delegate

import UIKit

// MARK: - Keyboard observers

extension CryptoListViewController {
  
  func setObservers() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver(self, selector: #selector(handleKeyboardEvent(_:)),
                                   name: UIWindow.keyboardWillShowNotification, object: nil)
    notificationCenter.addObserver(self, selector: #selector(handleKeyboardEvent(_:)),
                                   name: UIWindow.keyboardWillHideNotification, object: nil)
  }
  
  @objc private func handleKeyboardEvent(_ notification: Notification) {
    guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
      return
    }
    
    let keyboardRectangle = keyboardFrame.cgRectValue
    let keyboardHeight = keyboardRectangle.height
    
    var contentInset = UIEdgeInsets.zero
    
    if notification.name == UIWindow.keyboardWillShowNotification {
      contentInset.bottom = keyboardHeight
    } else if notification.name == UIWindow.keyboardWillHideNotification {
      let bottomSpace: CGFloat = view.safeAreaInsets.bottom > 0 ? 16.0 : 8.0
      contentInset.bottom = max(view.safeAreaInsets.bottom + bottomSpace, 50)
    }
    
    tableView.contentInset = contentInset
    tableView.scrollIndicatorInsets = contentInset
  }
  
}

// MARK: - UITableView delegate

extension CryptoListViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let item = listDataSource?.itemIdentifier(for: indexPath) else { return }
    listener.didTapOnCoin(item)
  }
}

// MARK: - UISearchController delegate

extension CryptoListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    listener.search(for: searchController.searchBar.text ?? "")
  }
}

extension CryptoListViewController: FilterTagViewDelegate {
  func didPressTag(tag: String, action: FilterAction) {
    listener.filterCoins(with: tag, action: action, searchPhrase: searchController.searchBar.text ?? "")
  }
}
