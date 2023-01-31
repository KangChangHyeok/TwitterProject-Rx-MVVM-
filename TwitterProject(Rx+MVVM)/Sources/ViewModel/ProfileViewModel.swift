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
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let followButtonTapped = BehaviorRelay<Void>(value: ())
        let buttonTitle = PublishRelay<String>()
    }
    struct Output {
        let userTweets: Observable<[Tweet]>
        let buttonTitle: BehaviorRelay<String>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let viewWillAppear = input.viewWillAppear.share()
        
        let userTweets = viewWillAppear
            .map({ [weak self] _ in
                return self?.user
            })
            .flatMap { user in
                TweetService.shared.fetchTweetsRx(user: user)
            }
        //
        let buttonTitle = BehaviorRelay(value: "Loading")
        
        UserService.shared.checkIfUserIsFollowedRx(uid: user.uid)
            .bind { [weak self] checkIfUserIsFollowed in
                if checkIfUserIsFollowed {
                    buttonTitle.accept("Following")
                } else {
                    if Auth.auth().currentUser?.uid == self?.user.uid {
                        buttonTitle.accept("Edit Profile")
                    } else {
                        buttonTitle.accept("Follow")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        input.followButtonTapped
            .withLatestFrom(input.buttonTitle)
            .withUnretained(self)
            .bind(onNext: { weakself, title in
                switch title {
                case "Follow":
                    UserService.shared.followUserRx(uid: (weakself.user.uid))
                        .subscribe(onNext: { _ in
                            buttonTitle.accept("Following")
                        })
                        .disposed(by: weakself.disposeBag)
                case "Following":
                    UserService.shared.unfollowUserRx(uid: (weakself.user.uid))
                        .subscribe(onNext: { _ in
                            buttonTitle.accept("Follow")
                        })
                        .disposed(by: weakself.disposeBag)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        return Output(userTweets: userTweets,
                      buttonTitle: buttonTitle)
    }
    
    func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
