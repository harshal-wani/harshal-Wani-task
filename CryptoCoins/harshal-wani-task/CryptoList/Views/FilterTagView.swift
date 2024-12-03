//
//  FilterTagView.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 03/12/24.
//

import UIKit
import TagListView
import SnapKit

final class FilterTagView: UIView {
  
  // MARK: Properties
  
  var tagPress: ((String, FilterAction) -> Void)?
  
  var tags: [String] = [] {
    didSet {
      tagView.addTags(tags)
    }
  }
  
  // MARK: - UI Elements
  
  private lazy var rootView: UIView = {
    let rootView = UIView()
    rootView.backgroundColor = .systemGray6
    return rootView
  }()
  
  private(set) lazy var tagView: TagListView = {
    let tagView = TagListView()
    tagView.textFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    tagView.alignment = .leading
    tagView.minimumContentSizeCategory = .medium
    tagView.delegate = self
    tagView.cornerRadius = 10
    tagView.textColor = .white
    tagView.backgroundColor = .systemGray6
    tagView.paddingX = 16
    tagView.paddingY = 12
    tagView.marginX = 16
    tagView.marginY = 12
    return tagView
  }()
  
  // MARK: Initializer
  
  init() {
    super.init(frame: .zero)
    self.setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupView() {
    self.addSubview(rootView)
    rootView.addSubview(tagView)
    
    rootView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    tagView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(16)
    }
  }
}

// MARK: TagListView Delegate

extension FilterTagView: TagListViewDelegate {
  
  func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
    guard let index = tags.firstIndex(of: title) else { return }
    
    let isSelected = title.contains("✅")
    tags[index] = isSelected ? title.replacingOccurrences(of: " ✅", with: "") : "\(title) ✅"
    
    let action: FilterAction = isSelected ? .remove : .add
    reloadTags()
    tagPress?(title.replacingOccurrences(of: " ✅", with: ""), action)
  }
  
  private func reloadTags() {
    tagView.removeAllTags()
    tagView.addTags(tags)
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
