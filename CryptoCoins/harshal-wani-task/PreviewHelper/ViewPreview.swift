//
//  ViewPreview.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 02/12/24.
//

import Foundation
import UIKit
import SwiftUI

/// This struct only available on Swish App
/// Use this inside of compiler flag `PREVIEW_ENABLED`
struct ViewPreview<UIViewType: UIView>: UIViewRepresentable {
  let factory: () -> UIViewType
  
  init(factory: @escaping () -> UIViewType) {
    self.factory = factory
  }
  
  init(_ view: @escaping @autoclosure () -> UIViewType) {
    self.factory = view
  }
  
  func makeUIView(context: Context) -> UIViewType {
    factory()
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) { }
  
}
