//
//  NotificationCellModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/06.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationCellModel {
    var disposeBag = DisposeBag()
    struct Input {
        let profileImageViewTapped = PublishRelay<UITapGestureRecognizer>()
    }
    struct Output {
        
    }
    let input = Input()
    lazy var output = transform(input: input)
    func transform(input: Input) -> Output {
//        let input.profileImageViewTapped
        return Output()
    }
    let notification: Notification
    let type: NotificationType
    let user: User
    
    var timestampString: String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: notification.timestamp, to: now) ?? "2m"
    }
    var notificationMessage: String {
        switch type {
        case .follow:
            return "started following you"
        case .like:
            return " liked one of your tweets"
        case .reply:
            return " replied to your tweet "
        case .retweet:
            return " retweeted your tweet"
        case .mention:
            return " mentioned you in a tweet "
        }
    }
    var notificationText: NSAttributedString? {
        guard let timestamp = timestampString else { return nil }
        let attributedText = NSMutableAttributedString(string: user.userName,
                                                       attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMessage,
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " \(timestamp)",
                                                 attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        return attributedText
    }
    init(notification: Notification) {
        self.notification = notification
        self.type = notification.type
        self.user = notification.user
    }
}
