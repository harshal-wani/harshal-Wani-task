//
//  CryptoDetailCoordinator.swift
//  harshal-wani-task
//
//  Created by Harshal Wani on 05/12/24.
//

import UIKit

final class CryptoDetailCoordinator: Coordinator {

  private var presenter: UINavigationController
  private var cryptoDetailViewController: CryptoDetailViewController?
  private let cryptoItem: CryptoItem

  init (presenter: UINavigationController, cryptoItem: CryptoItem) {
    self.presenter = presenter
    self.cryptoItem = cryptoItem
  }
  
  func start() {
    let viewController = CryptoDetailViewController()
    self.cryptoDetailViewController = viewController
    presenter.pushViewController(viewController, animated: true)
  }
}
