//
//  TweetCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/03.
//

import UIKit
import SnapKit
import RxSwift

class TweetCell: UICollectionViewCell {
    
    // MARK: - Properties
    var cellModel: TweetCellModel!
    var disposeBag = DisposeBag()
    
    let profileImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()

    let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let informationLabel = UILabel()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .darkGray
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        return button
    }()
    private lazy var retweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.tintColor = .darkGray
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        return button
    }()
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like"), for: .normal)
        button.tintColor = .darkGray
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "share"), for: .normal)
        button.tintColor = .darkGray
        button.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        return button
    }()
    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 8, bottom: 0, right: 0))
        }
        let stackView = UIStackView(arrangedSubviews: [informationLabel, captionLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 4
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12))
        }
        
        
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        informationLabel.font = UIFont.systemFont(ofSize: 14)
        
        let actionStackView = UIStackView(arrangedSubviews: [commentButton, retweetButton, likeButton, shareButton])
        actionStackView.axis = .horizontal
        actionStackView.distribution = .fillEqually
        actionStackView.spacing = 72
        addSubview(actionStackView)
        actionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(underlineView.snp.top).offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        profileImageView.sd_setImage(with: cellModel.profileImageUrl)
        captionLabel.text = cellModel.captionLabelText
        informationLabel.attributedText = cellModel.informationText
    }
    
}


