//
//  ProfileFilterCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/17.
//

import UIKit
import SnapKit

final class ProfileFilterCell: UICollectionViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? .twitterBlue : .lightGray
        }
    }
    override func layoutSubviews() {
        setValue()
        addSubViews()
        layout()
    }
}

extension ProfileFilterCell: LayoutProtocol {
    func setValue() {
        backgroundColor = .white
    }
    func addSubViews() {
        addSubview(titleLabel)
    }
    func layout() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
