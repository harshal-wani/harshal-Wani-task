//
//  CryptoCoinCell.swift
//  CryptoCoins
//
//  Created by Harshal Wani on 02/12/24.
//

import UIKit
import SnapKit

final class CryptoCoinCell: UITableViewCell {
  
  // MARK: - Static Properties
  
  static let identifier = "CryptoCoinCell"
  
  // MARK: - UI Elements
  
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    label.textColor = .secondaryLabel
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let codeLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
    label.textColor = .systemGray
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private let coinImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let newImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.image = UIImage(named: "ic-new")
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let emptyView: UIView = UIView()
  
  // MARK: - Initializers
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupViews()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupViews()
  }
  
  // MARK: - Lifecycle Methods
  
  override func prepareForReuse() {
    super.prepareForReuse()
    nameLabel.text = nil
    codeLabel.text = nil
    coinImageView.image = nil
    newImageView.alpha = 0
  }
  
  // MARK: - Setup Methods
  
  private func setupViews() {
    // Label StackView
    let labelStackView = UIStackView(arrangedSubviews: [nameLabel, codeLabel])
    labelStackView.axis = .vertical
    labelStackView.alignment = .leading
    labelStackView.spacing = 8
    
    // Image Constraints
    coinImageView.snp.makeConstraints { make in
      make.width.height.equalTo(40)
    }
    newImageView.snp.makeConstraints { make in
      make.width.height.equalTo(20)
    }
    emptyView.snp.makeConstraints { make in
      make.height.equalTo(15)
    }
    
    // Icon StackView
    let iconStackView = UIStackView(arrangedSubviews: [newImageView, coinImageView, emptyView])
    iconStackView.axis = .vertical
    iconStackView.alignment = .trailing
    iconStackView.spacing = 4
    
    // Root StackView
    let rootStackView = UIStackView(arrangedSubviews: [labelStackView, iconStackView])
    rootStackView.axis = .horizontal
    rootStackView.alignment = .center
    rootStackView.spacing = 16
    contentView.addSubview(rootStackView)
    
    // Root StackView Constraints
    rootStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(8)
    }
  }
  
  // MARK: - Private Methods
  
  private func getCryptoIcon(for type: CryptoType, isActive: Bool) -> UIImage? {
    
    guard isActive else { return UIImage(named: "ic-inactive") }
    
    switch type {
    case .coin:
      return UIImage(named: "ic-coin")
    case .token:
      return UIImage(named: "ic-token")
    case .unknown:
      return nil
    }
  }
  
  // MARK: - Public Methods
  
  func style(with model: CryptoItem) {
    nameLabel.text = model.name
    codeLabel.text = model.symbol
    newImageView.alpha = model.isNew ? 1 : 0
    coinImageView.image = getCryptoIcon(for: model.type, isActive: model.isActive)
  }
}


#if DEBUG
import SwiftUI

struct CryptoCoinCell_Previews: PreviewProvider {
  
  static var previews: some View {
    ViewPreview {
      do {
        let jsonData = Data("""
        {
            "name": "Monero",
            "symbol": "XMR",
            "is_new": false,
            "is_active": true,
            "type": "coin"
          }
        """.utf8)
        let mock: CryptoItem = try JSONDecoder().decode(CryptoItem.self, from: jsonData)
        let view = CryptoCoinCell()
        view.style(with: mock)
        return view
      } catch {
        return UIView()
      }
    }
    .previewLayout(.fixed(width: 383, height: 100))
  }
}
#endif
