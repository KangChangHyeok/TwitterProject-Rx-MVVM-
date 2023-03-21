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

final class NotificationCell: UITableViewCell {
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
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
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
        setValue()
        addSubViews()
        layout()
    }
    func bind() {
        profileImageView.sd_setImage(with: cellModel.notification.user.profileImageUrl)
        notificationLabel.attributedText = cellModel.notificationText
    }
    override func prepareForReuse() {
        disposeBag = DisposeBag()
    }
}
extension NotificationCell: LayoutProtocol {
    func setValue() {
        self.selectionStyle = .none
    }
    func addSubViews() {
        contentView.addSubview(stackView)
    }
    func layout() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
    }
}
