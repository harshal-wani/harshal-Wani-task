//
//  CryptoListCoordinator.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 30/11/24.
//

import UIKit

final class CryptoListCoordinator: Coordinator {

    private var presenter: UINavigationController
    private var listViewController: CryptoListViewController?

    init(presenter: UINavigationController) {
        self.presenter = presenter
    }

    func start() {
      let dataProvider = CryptoDataProvider(apiService: APIService.shared)
      let viewModel = CryptoViewModel(dataProvider: dataProvider)
      let listViewController = CryptoListViewController(viewModel: viewModel)
      self.listViewController = listViewController
      presenter.pushViewController(listViewController, animated: true)
    }
}
