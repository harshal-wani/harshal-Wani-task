//
//  CryptoDetailViewController.swift
//  harshal-wani-task
//
//  Created by Harshal Wani on 05/12/24.
//

import UIKit
import SnapKit

final class CryptoDetailViewController: UIViewController {
  
  lazy var detailLabel: UILabel = {
    let label = UILabel()
    label.textColor = .black
    label.font = .systemFont(ofSize: 16)
    label.numberOfLines = 0
    label.textAlignment = .center
    label.text = "Detail View"
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  view.backgroundColor = .white
    view.addSubview(detailLabel)
    
    detailLabel.snp.makeConstraints { make in
      make.centerX.centerY.equalToSuperview()
    }
  }
}
