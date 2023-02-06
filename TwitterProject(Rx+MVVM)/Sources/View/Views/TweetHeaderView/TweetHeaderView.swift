//
//  TweetHeaderView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit
import SnapKit
import SDWebImage
import RxSwift
import RxCocoa

class TweetHeaderView: UIView {
    // MARK: - properties
    var viewModel: TweetHeaderViewModel
    var disposeBag = DisposeBag()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 48 / 2
        imageView.setupSize(height: 48, width: 48)
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    private lazy var arrangedSubviewsInNameStackView = [fullnameLabel, usernameLabel]
    private lazy var nameStackView: UIStackView = {
        let nameStackView = UIStackView(arrangedSubviews: arrangedSubviewsInNameStackView)
        nameStackView.axis = .vertical
        nameStackView.spacing = -6
        return nameStackView
    }()
    private lazy var arrangedSubviewsInuserDataStackView = [profileImageView, nameStackView]
    private lazy var userDataStackView: UIStackView = {
        let userDataStackView = UIStackView(arrangedSubviews: arrangedSubviewsInuserDataStackView)
        userDataStackView.axis = .horizontal
        userDataStackView.spacing = 12
        return userDataStackView
    }()
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .lightGray
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        return button
    }()
    private lazy var statsView: StatsView = {
        let statsViewModel = StatsViewModel(tweet: viewModel.tweet)
        let statsView = StatsView(viewModel: statsViewModel)
        statsView.bind()
        return statsView
    }()
    private lazy var commentButton: UIButton = {
        let button = createButton(withImageName: "comment")
        return button
    }()
    private lazy var retweetButton: UIButton = {
        let button = createButton(withImageName: "retweet")
        return button
    }()
    private lazy var likeButton: UIButton = {
        let button = createButton(withImageName: "like")
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = createButton(withImageName: "share")
        return button
    }()
    private lazy var arrangedSubviewsInActionStackView = [commentButton, retweetButton, likeButton, shareButton]
    private lazy var actionStackView: UIStackView = {
        let actionStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionStackView.spacing = 72
        return actionStackView
    }()
    private lazy var actionSheet = ActionSheetLauncher(user: viewModel.tweet.user)
    init(viewModel: TweetHeaderViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        backgroundColor = .systemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        
        addSubview(userDataStackView)
        addSubview(captionLabel)
        addSubview(dateLabel)
        addSubview(optionsButton)
        addSubview(statsView)
        addSubview(actionStackView)
        
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
            make.right.equalToSuperview().offset(-8)
        }
        statsView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        arrangedSubviewsInActionStackView.forEach { button in
            button.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
        actionStackView.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(statsView.snp.bottom).offset(16)
        }
    }
    func bind() {
        profileImageView.sd_setImage(with: viewModel.tweet.user.profileImageUrl)
        fullnameLabel.text = viewModel.tweet.user.fullName
        usernameLabel.text = viewModel.tweet.user.userName
        captionLabel.text = viewModel.tweet.caption
        dateLabel.text = viewModel.headerTimeStamp
        optionsButton.rx.tap
            .withUnretained(self)
            .bind { weakself, _ in
                weakself.actionSheet.show()
            }
            .disposed(by: disposeBag)
        likeButton.rx.tap
            .bind(to: viewModel.input.likeButtonTapped)
            .disposed(by: disposeBag)
        viewModel.output.userLikeForTweet
            .drive(onNext: { result in
                if result {
                    self.likeButton.tintColor = .red
                    self.statsView.viewModel.input.userLikesChange.accept(())
                } else {
                    self.likeButton.tintColor = .gray
                    self.statsView.viewModel.input.userLikesChange.accept(())
                }
                
            })
            .disposed(by: disposeBag)
        viewModel.output.checkIfUserLikeTweet
            .drive(onNext: { result in
                if result {
                    self.likeButton.tintColor = .red
                } else {
                    self.likeButton.tintColor = .gray
                }
            })
            .disposed(by: disposeBag)
    }
    private func createButton(withImageName imageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.tintColor = .darkGray
        return button
    }
}
