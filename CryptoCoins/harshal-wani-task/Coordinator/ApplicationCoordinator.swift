//
//  ApplicationCoordinator.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 30/11/24.
//

import UIKit

protocol Coordinator {
  func start()
}

final class ApplicationCoordinator: Coordinator {
  
  private let window: UIWindow
  private let rootViewController: UINavigationController
  private var listCoordinator: CryptoListCoordinator?
  
  init(window: UIWindow) {
    self.window = window
    rootViewController = UINavigationController()
    listCoordinator = CryptoListCoordinator(presenter: rootViewController)
  }
  
  func start() {
    window.rootViewController = rootViewController
    listCoordinator?.start()
    window.makeKeyAndVisible()
  }
  
}
