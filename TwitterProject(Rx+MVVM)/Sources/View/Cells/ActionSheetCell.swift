//
//  ActionSheetCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/05.
//
import UIKit

class ActionSheetCell: UITableViewCell {

    private let optionImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "twitter_logo_blue")
        return iv
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "Test Option"
        return label
    }()
    // MARK: - Lifecycle
    override func layoutSubviews() {
        addSubViews()
        layout()
    }
}

extension ActionSheetCell: LayoutProtocol {
    func addSubViews() {
        addSubview(optionImageView)
        addSubview(titleLabel)
    }
    func layout() {
        optionImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self.snp.left).offset(8)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(optionImageView.snp.right).offset(12)
        }
    }
}
