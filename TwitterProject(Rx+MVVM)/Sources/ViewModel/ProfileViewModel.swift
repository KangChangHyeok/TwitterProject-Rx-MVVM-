//
//  ProfileViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/16.
//

import Foundation
import SDWebImage
import FirebaseAuth
import RxSwift
import RxCocoa


class ProfileViewModel: ViewModelType {
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let headerBindViewModel = PublishRelay<Void>()
    }
    struct Output {
        let userTweets: Observable<[Tweets]>
        let profileImageUrl: Driver<URL?>
        let userName: Observable<String>
        let fullName: Observable<String>
        let followersString: Observable<NSAttributedString?>
        let follwingString: Observable<NSAttributedString?>
        let buttonTitle: Observable<String>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        //input- viewWillAppear
        
        let userTweets = input.viewWillAppear
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .flatMap { user in
                TweetService.shared.fetchTweetsRx(user: user)
            }
            .map { tweets in
                return [Tweets(items: tweets)]
            }
        //input- headerBindViewModel
        let user = input.headerBindViewModel.flatMap { _ in
            UserService.shared.fetchUserRx()
        }.share()
        
        let profileImageUrl = user
            .map { user in
                return user.profileImageUrl
            }
            .asDriver(onErrorDriveWith: .empty())
        let userName = user
            .map { user in
                return "@\(user.userName)"
            }
        let fullName = user
            .map { user in
                return user.fullName
            }
        let followersString = user
            .map { [weak self] user in
                return self?.attributedText(withValue: 0, text: "followers")
            }
        let followingString = user
            .map { [weak self] user in
                return self?.attributedText(withValue: 2, text: "following")
            }
        let actionButtonTitle = user
            .map { user in
                if Auth.auth().currentUser?.uid == user.uid {
                    return "Edit Profile"
                } else {
                    return "Follow"
                }
            }
        return Output(userTweets: userTweets,
                      profileImageUrl: profileImageUrl,
                      userName: userName,
                      fullName: fullName,
                      followersString: followersString,
                      follwingString: followingString,
                      buttonTitle: actionButtonTitle)
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
