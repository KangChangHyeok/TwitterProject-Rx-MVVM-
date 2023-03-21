//
//  UserCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/30.
//

import UIKit

final class UserCell: UITableViewCell {
    // MARK: - UI
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "userName"
        label.numberOfLines = 0
        return label
    }()
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "fullName"
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [userNameLabel, fullNameLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    override func layoutSubviews() {
        setValue()
        addSubViews()
        layout()
    }
    func bind(user: User) {
        profileImageView.sd_setImage(with: user.profileImageUrl)
        userNameLabel.text = user.userName
        fullNameLabel.text = user.fullName
    }
}
extension UserCell: LayoutProtocol {
    func setValue() {
        backgroundColor = .systemBackground
    }
    func addSubViews() {
        addSubview(profileImageView)
        addSubview(stackView)
    }
    func layout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.left.equalTo(profileImageView.snp.right).offset(12)
        }
    }
}
