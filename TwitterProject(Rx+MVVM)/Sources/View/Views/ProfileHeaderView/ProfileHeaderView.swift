//
//  ProfileHeader.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/16.
//

import UIKit
import SDWebImage
import RxCocoa
import RxSwift

class ProfileHeaderView: UIView {
    // MARK: - properties

    var disposeBag = DisposeBag()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_white_24dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    private let editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 36 / 2
        return button
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        imageView.layer.cornerRadius = 80 / 2
        return imageView
    }()
    private lazy var userDetailsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fullNameLabel, userNameLabel, bioLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        return stackView
    }()
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.text = "This is a user bio that will span more than on line for test purposes"
        return label
    }()
    private lazy var followStack: UIStackView = {
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal
        followStack.spacing = 8
        followStack.distribution = .fillEqually
        return followStack
    }()
    private let followingLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    private let followersLabel: UILabel = {
        let label = UILabel()
        label.isUserInteractionEnabled = true
        return label
    }()
    let filterBar = ProfileFilterView()
    
    // MARK: - Override
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        
        addSubview(containerView)
        containerView.addSubview(backButton)
        addSubview(editProfileFollowButton)
        addSubview(profileImageView)
        addSubview(userDetailsStackView)
        addSubview(followStack)
        addSubview(filterBar)
        
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(108)
        }
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 42, left: 16, bottom: 0, right: 0))
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(-24)
            make.leading.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        userDetailsStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }
        followStack.snp.makeConstraints { make in
            make.top.equalTo(userDetailsStackView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(12)
        }
        editProfileFollowButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        filterBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
    }
    func bind(viewModel: ProfileViewModel) {
    
        backButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                let profileViewController = self?.superViewController as? ProfileViewController
                profileViewController?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        editProfileFollowButton.rx.tap
            .bind(to: viewModel.input.followButtonTapped)
            .disposed(by: disposeBag)
        profileImageView.sd_setImage(with: viewModel.user.profileImageUrl)
        fullNameLabel.text = viewModel.user.fullName
        userNameLabel.text = viewModel.user.userName
        followersLabel.attributedText = viewModel.attributedText(withValue: 2, text: "Follows")
        followingLabel.attributedText = viewModel.attributedText(withValue: 0, text: "Following")
        // output - buttonTitle
        viewModel.output.buttonTitle
            .bind(to: editProfileFollowButton.rx.title())
            .disposed(by: disposeBag)
        viewModel.output.buttonTitle
            .bind(to: viewModel.input.buttonTitle)
            .disposed(by: disposeBag)
        viewModel.output.followerUsersCount
            .bind(to: followersLabel.rx.attributedText)
            .disposed(by: disposeBag)
        viewModel.output.followingUsersCount
            .bind(to: followingLabel.rx.attributedText)
            .disposed(by: disposeBag)
    }
}
