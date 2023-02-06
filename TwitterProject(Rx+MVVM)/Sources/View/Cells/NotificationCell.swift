//
//  NotificationCell.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/06.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class NotificationCell: UITableViewCell {
    // MARK: - Properties
    var cellModel: NotificationCellModel!
    var disposeBag = DisposeBag()
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40 / 2
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .twitterBlue
        return iv
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 32 / 2
        return button
    }()
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Some tset notification message"
        return label
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImageView, notificationLabel])
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    // MARK: - Lifecycle
    override func layoutSubviews() {
        self.selectionStyle = .none
        contentView.addSubview(stackView)
        contentView.addSubview(followButton)
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        followButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 92, height: 32))
            make.right.equalToSuperview().offset(-12)
        }

    }
    func bind() {
        profileImageView.sd_setImage(with: cellModel.notification.user.profileImageUrl)
        notificationLabel.attributedText = cellModel.notificationText
        profileImageView.rx.tapGesture()
            .when(.recognized)
            .bind(to: cellModel.input.profileImageViewTapped)
            .disposed(by: disposeBag)
            
    }
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
