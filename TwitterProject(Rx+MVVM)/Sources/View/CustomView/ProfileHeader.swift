//
//  ProfileHeader.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/16.
//

import UIKit

class ProfileHeader: UICollectionReusableView {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 42, left: 16, bottom: 0, right: 0))
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_white_24dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        return button
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        return imageView
    }()
    
    private lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.twitterBlue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()

    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "Joker"
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "@venom"
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 3
        label.text = "This is a user bio that will span more than on line for test purposes"
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(108)
        }
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(-24)
            make.leading.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        profileImageView.layer.cornerRadius = 80 / 2
        
        addSubview(editProfileFollowButton)
        editProfileFollowButton.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.bottom).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.size.equalTo(CGSize(width: 100, height: 36))
        }
        editProfileFollowButton.layer.cornerRadius = 36 / 2
        
        let userDetailsStackView = UIStackView(arrangedSubviews: [fullNameLabel, userNameLabel, bioLabel])
        userDetailsStackView.axis = .vertical
        userDetailsStackView.distribution = .fillProportionally
        userDetailsStackView.spacing = 4
        
        addSubview(userDetailsStackView)
        userDetailsStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
