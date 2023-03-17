//
//  RetweetCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/15.
//

import UIKit

import SDWebImage
import ActiveLabel

final class RetweetCell: UITableViewCell {
    // MARK: - UI
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        return label
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    private let informationLabel: UILabel = {
        let informationLabel = UILabel()
        informationLabel.font = UIFont.systemFont(ofSize: 14)
        return informationLabel
    }()
    private lazy var userDataStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [informationLabel, captionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()
    override func layoutSubviews() {
        addSubViews()
        layout()
    }
    func bind(tweet: Tweet) {
        profileImageView.sd_setImage(with: tweet.user.profileImageUrl)
        captionLabel.text = tweet.caption
        informationLabel.attributedText = tweet.informationText
        replyLabel.text = tweet.replyText
    }
}
// MARK: - LayoutProtocol
extension RetweetCell: LayoutProtocol {
    func addSubViews() {
        contentView.addSubview(replyLabel)
        contentView.addSubview(profileImageView)
        contentView.addSubview(userDataStackView)
    }
    func layout() {
        replyLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(replyLabel.snp.bottom).offset(8)
            make.left.equalTo(replyLabel.snp.left)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        userDataStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
