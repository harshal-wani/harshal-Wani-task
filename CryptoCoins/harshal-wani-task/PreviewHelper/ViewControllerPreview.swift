//
//  ViewControllerPreview.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 02/12/24.
//


import Foundation
import SwiftUI

/// This struct only available on Swish App
/// Use this inside of compiler flag `PREVIEW_ENABLED`
struct ViewControllerPreview<UIViewControllerType: UIViewController>: UIViewControllerRepresentable {
  let factory: () -> UIViewControllerType
  
  init(factory: @escaping () -> UIViewControllerType) {
    self.factory = factory
  }
  
  init(_ viewController: @escaping @autoclosure () -> UIViewControllerType) {
    self.factory = viewController
  }
  
  func makeUIViewController(context: Context) -> UIViewControllerType {
    factory()
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
  
}

extension ViewControllerPreview {
  typealias InNavigation = InNavigationViewControllerPreview<UIViewControllerType>
}

/// This struct only available on Swish App
/// Use this inside of compiler flag `PREVIEW_ENABLED`
struct InNavigationViewControllerPreview<Wrapped: UIViewController>: UIViewControllerRepresentable {
  typealias UIViewControllerType = UINavigationController
  let factory: () -> Wrapped
  
  init(factory: @escaping () -> Wrapped) {
    self.factory = factory
  }
  
  init(_ viewController: @escaping @autoclosure () -> Wrapped) {
    self.factory = viewController
  }
  
  func makeUIViewController(context: Context) -> UIViewControllerType {
    UINavigationController(rootViewController: factory())
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
  
}
