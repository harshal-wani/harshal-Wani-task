//
//  FilterTagView.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 03/12/24.
//

import UIKit
import TagListView
import SnapKit


protocol FilterTagViewDelegate: AnyObject {
  func didPressTag(tag: String, action: FilterAction)
}

final class FilterTagView: UIView {
  
  // MARK: - Properties
  
  private let selectedTick = "✅"
  
  var tags: [String] = [] {
    didSet { updateTags() }
  }
  
  weak var delegate: FilterTagViewDelegate?
  
  // MARK: - UI Elements
  
  private lazy var rootView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray6
    return view
  }()
  
  private lazy var tagView: TagListView = {
    let view = TagListView()
    view.textFont = .systemFont(ofSize: 16, weight: .medium)
    view.alignment = .leading
    view.minimumContentSizeCategory = .medium
    view.delegate = self
    view.cornerRadius = 10
    view.textColor = .white
    view.backgroundColor = .systemGray6
    view.paddingX = 16
    view.paddingY = 12
    view.marginX = 16
    view.marginY = 12
    return view
  }()
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup Methods
  
  private func setupView() {
    addSubview(rootView)
    rootView.addSubview(tagView)
    
    rootView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    tagView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(16)
    }
  }
  
  private func updateTags() {
    tagView.removeAllTags()
    tagView.addTags(tags)
  }
}

// MARK: - TagListViewDelegate

extension FilterTagView: TagListViewDelegate {
  
  func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
    guard let index = tags.firstIndex(of: title) else { return }
    
    let isSelected = title.contains(selectedTick)
    let cleanTitle = title.replacingOccurrences(of: " \(selectedTick)", with: "")
    tags[index] = isSelected ? cleanTitle : "\(title) \(selectedTick)"
    
    updateTags()
    let action: FilterAction = isSelected ? .remove : .add
    delegate?.didPressTag(tag: cleanTitle, action: action)
  }
}

#if DEBUG
import SwiftUI

struct FilterTagView_Previews: PreviewProvider {
  
  static var previews: some View {
    ViewPreview {
      let view = FilterTagView()
      view.tags = ["✅ Coin", "Token", "New"]
      return view
    }
    .previewLayout(.fixed(width: 383, height: 100))
  }
}
#endif
