//
//  TweetCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/03.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture

class TweetCell: UICollectionViewCell {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    var cellModel: TweetCellModel!
    
    let profileImageView: UIImageView = {
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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [informationLabel, captionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    private let retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        return button
    }()
    private lazy var arrangedSubviewsInActionStackView = [commentButton, retweetButton, likeButton, shareButton]
    private lazy var actionStackView: UIStackView = {
        let actionStackView = UIStackView(arrangedSubviews: arrangedSubviewsInActionStackView)
        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 72
        return actionStackView
    }()
    private let underlineView: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        return underlineView
    }()
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        addSubview(profileImageView)
        addSubview(stackView)
        addSubview(underlineView)
        addSubview(actionStackView)
        
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0))
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12))
        }
        arrangedSubviewsInActionStackView.forEach { subView in
            subView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 20, height: 20))
            }
        }
        actionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(underlineView.snp.top).offset(-8)
        }
        underlineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    func bind() {
        profileImageView.sd_setImage(with: cellModel.profileImageUrl)
        profileImageView.rx
            .tapGesture()
            .when(.recognized)
            .map({ _ in
                ()
            })
            .withUnretained(self)
            .subscribe(onNext: { weakself, _ in
                guard let feedViewController = weakself.superViewController as? FeedViewController else { return }
                feedViewController.viewModel.input.cellProfileImageTapped.accept(weakself.cellModel.tweet.user)
            })
            .disposed(by: disposeBag)
        informationLabel.attributedText = cellModel.informationText
        captionLabel.text = cellModel.captionLabelText
        commentButton.rx.tap
            .withUnretained(self)
            .bind { weakself, _ in
                guard let feedViewController = weakself.superViewController as? FeedViewController else { return }
                feedViewController.viewModel.input.cellRetweetButtonTapped.accept(weakself.cellModel.tweet)
            }
            .disposed(by: disposeBag)
        likeButton.rx.tap
            .bind(to: cellModel.input.likeButtonTapped)
            .disposed(by: disposeBag)
        cellModel.output.userLikeForTweet
            .drive(onNext: { result in
                if result {
                    self.likeButton.tintColor = .red
                } else {
                    self.likeButton.tintColor = .gray
                }
            })
            .disposed(by: disposeBag)
        cellModel.output.checkIfUserLikeTweet
            .drive(onNext: { result in
                if result {
                    self.likeButton.tintColor = .red
                } else {
                    self.likeButton.tintColor = .gray
                }
            })
            .disposed(by: disposeBag)
    }
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}


