//
//  TweetHeaderView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit

import SnapKit
import RxSwift

final class TweetHeaderView: UIView {
    // MARK: - UI
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        return imageView
    }()
    let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    private lazy var nameStackView: UIStackView = {
        let nameStackView = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        nameStackView.axis = .vertical
        nameStackView.spacing = -6
        return nameStackView
    }()
    private lazy var userDataStackView: UIStackView = {
        let userDataStackView = UIStackView(arrangedSubviews: [profileImageView, nameStackView])
        userDataStackView.axis = .horizontal
        userDataStackView.spacing = 12
        return userDataStackView
    }()
    let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        return button
    }()
    lazy var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "comment")
        return button
    }()
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        return button
    }()
    lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        button.tintColor = .red
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        return button
    }()
    private lazy var actionStackView: UIStackView = {
        let actionStackView = UIStackView(arrangedSubviews: [retweetButton, commentButton, likeButton, shareButton])
        actionStackView.spacing = 72
        return actionStackView
    }()
//    lazy var actionSheet = ActionSheetLauncher(user: viewModel.tweet.user)
    // MARK: -
    override func layoutSubviews() {
        setValue()
        addSubViews()
        layout()
    }
    func bind(viewModel tweetViewModel: TweetViewModel, disposeBag: DisposeBag) {
        // MARK: - viewModel Input
        retweetButton.rx.tap
            .bind(to: tweetViewModel.input.retweetButtonTapped)
            .disposed(by: disposeBag)
        likeButton.rx.tap
            .bind(to: tweetViewModel.input.likeButtonTapped)
            .disposed(by: disposeBag)
        
        tweetViewModel.output.profileImageUrl
            .withUnretained(self)
            .bind { tweetViewController, url in
                tweetViewController.profileImageView.sd_setImage(with: url)
            }
            .disposed(by: disposeBag)
        tweetViewModel.output.userFullName
            .bind(to: fullnameLabel.rx.text)
            .disposed(by: disposeBag)
        tweetViewModel.output.userName
            .bind(to: usernameLabel.rx.text)
            .disposed(by: disposeBag)
        tweetViewModel.output.caption
            .bind(to: captionLabel.rx.text)
            .disposed(by: disposeBag)
        tweetViewModel.output.date
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        tweetViewModel.output.retweetCount
            .bind(to: statsView.retweetsLabel.rx.attributedText)
            .disposed(by: disposeBag)
        tweetViewModel.output.likesCount
            .bind(to: statsView.likesLabel.rx.attributedText)
            .disposed(by: disposeBag)
        tweetViewModel.output.likeButtonImage
            .bind(to: likeButton.rx.image())
            .disposed(by: disposeBag)
    }
}
extension TweetHeaderView: LayoutProtocol {
    func setValue() {
        backgroundColor = .systemBackground
    }
    func addSubViews() {
        addSubview(userDataStackView)
        addSubview(captionLabel)
        addSubview(dateLabel)
        addSubview(optionsButton)
        addSubview(statsView)
        addSubview(actionStackView)
    }
    func layout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        userDataStackView.snp.makeConstraints { make in
            make.top.left.equalTo(self.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0))
        }
        captionLabel.snp.makeConstraints { make in
            make.top.equalTo(userDataStackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(captionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            
        }
        optionsButton.snp.makeConstraints { make in
            make.centerY.equalTo(userDataStackView)
            make.right.equalToSuperview().offset(-10)
        }
        statsView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        actionStackView.arrangedSubviews.forEach { view in
            view.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
        actionStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(statsView.snp.bottom).offset(16)
        }
    }
    func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        return button
    }
}
