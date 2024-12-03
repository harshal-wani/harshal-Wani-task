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
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)),
                                           name: UIWindow.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)),
                                           name: UIWindow.keyboardWillHideNotification, object: nil)
  }
  
  @objc func keyboardShow(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      var contentInset = UIEdgeInsets.zero
      contentInset.bottom = keyboardHeight
      tableView.contentInset = contentInset
    }
  }
  
  @objc func keyboardHide(_ notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      let keyboardHeight = keyboardRectangle.height
      var contentInset = UIEdgeInsets.zero
      let bottomSpace: CGFloat = (view.safeAreaInsets.bottom) > 0 ? 16.0 : 8.0
      contentInset.bottom =  view.safeAreaInsets.bottom + bottomSpace
      if keyboardHeight < 50 { contentInset.bottom = 50 }
      tableView.contentInset = contentInset
      tableView.scrollIndicatorInsets = contentInset
    }
  }
  
}

// MARK: - UITableView delegate

extension CryptoListViewController: UITableViewDelegate {
  
}

// MARK: - UISearchController delegate

extension CryptoListViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    listener.search(for: searchController.searchBar.text ?? "")
  }
}
