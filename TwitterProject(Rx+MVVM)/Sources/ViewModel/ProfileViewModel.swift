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
    
    var user: User?
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let userProfileImageUrl: Driver<URL?>
        let followersString: Observable<NSAttributedString>
        let followingString: Observable<NSAttributedString>
        let userFullName: Observable<String?>
        let userName: Observable<String?>
        let editProfileButtonTitle: Observable<String>
        let followButtonTitle: Observable<String>
        let userTweets: Observable<[Tweet]>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let userProfileImageUrl = Observable.just(user?.profileImageUrl).asDriver(onErrorDriveWith: .empty())
        let followersString = Observable.just(attributedText(withValue: 0, text: "followers"))
        let followingString = Observable.just(attributedText(withValue: 2, text: "following"))
        let userFullName = Observable.just(user?.fullName)
        let userName = Observable.just(user?.userName)
        
        let currentUser = Observable<Bool>.create { [weak self] observer in
            if Auth.auth().currentUser?.uid == self?.user?.uid {
                observer.onNext(true)
                observer.onCompleted()
            } else {
                observer.onNext(false)
                observer.onCompleted()
            }
            return Disposables.create()
        }
            .share()
        let editProfileString = currentUser.filter { $0 == true }
            .map { _ in
                return "Edit Profile"
            }
        
        let followString = currentUser.filter { $0 == false }
            .map { _ in
                return "Follow"
            }
        
        let userTweets = input.viewWillAppear
            .flatMap { [ weak self] _ in
                TweetService.shared.fetchTweetsRx(user: self?.user)
            }
        return Output(userProfileImageUrl: userProfileImageUrl,
                      followersString: followersString,
                      followingString: followingString,
                      userFullName: userFullName,
                      userName: userName,
                      editProfileButtonTitle: editProfileString,
                      followButtonTitle: followString,
                      userTweets: userTweets)
    }
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
