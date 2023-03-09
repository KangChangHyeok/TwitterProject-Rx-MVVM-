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
        let followerUsersCount: PublishRelay<NSAttributedString>
        let followingUsersCount: PublishRelay<NSAttributedString>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let viewWillAppear = input.viewWillAppear.share()
        // 뷰가 화면에 뜨기 전에 cell에 넣어줄 유저들 트윗 가져오기
        let userTweets = viewWillAppear
            .map({ [weak self] _ in
                return self?.user
            })
            .flatMap { user in
                TweetService.shared.fetchTweetsRx(user: user)
            }
        
        let followerUsersCount = PublishRelay<NSAttributedString>()
        
        // 뷰가 화면에 뜨기 전에 표시할 해당 유저의 팔로워 가져오기
        let getFollowerUsersCount = viewWillAppear
            .withUnretained(self)
            .flatMap { weakself, _ in
                UserService.shared.fetchFollowerUsersRx(uid: weakself.user.uid)
            }
            .withUnretained(self)
            .map { weakself, followerUsersCount in
                weakself.attributedText(withValue: followerUsersCount, text: "팔로워")
            }
        // 바인딩
        getFollowerUsersCount
            .bind(to: followerUsersCount)
            .disposed(by: disposeBag)
        
        let followingUsersCount = PublishRelay<NSAttributedString>()
        
        // 뷰가 화면에 표시되기 전에 해당 유저가 팔로잉한 유저 가져오기
        let getFollowingUsersCount = viewWillAppear
            .withUnretained(self)
            .flatMap { weakself, _ in
                UserService.shared.fetchFollowingUsersRx(uid: weakself.user.uid)
            }
            .withUnretained(self)
            .map { weakself, followingUsersCount in
                weakself.attributedText(withValue: followingUsersCount, text: "팔로잉")
            }
        // 바인딩
        getFollowingUsersCount
            .bind(to: followingUsersCount)
            .disposed(by: disposeBag)
        
        let buttonTitle = BehaviorRelay(value: "Loading")
        // 버튼 타이틀 초기값
        UserService.shared.checkIfUserIsFollowedRx(uid: user.uid)
            .bind { [weak self] checkIfUserIsFollowed in
                // 유저를 팔로잉 한 상태일 경우
                if checkIfUserIsFollowed {
                    buttonTitle.accept("팔로잉")
                } else {
                    // 유저를 팔로잉한 상태가 아닐 경우
                    if Auth.auth().currentUser?.uid == self?.user.uid {
                        // 자신의 프로필이라면
                        buttonTitle.accept("프로필 수정")
                    } else {
                        // 다른 사람의 프로필이라면
                        buttonTitle.accept("팔로우")
                    }
                }
            }
            .disposed(by: disposeBag)
        // 버튼을 탭 했을때
        input.followButtonTapped
            .withLatestFrom(input.buttonTitle)
            .withUnretained(self)
            .bind(onNext: { weakself, title in
                switch title {
                    // 팔로우를 하지 않았을 경우 유저 팔로잉하기
                case "팔로우":
                    UserService.shared.followUserRx(uid: (weakself.user.uid))
                        .subscribe(onNext: { _ in
                            NotificationService.shared.uploadNotification(toUser: self.user, type: .follow)
                            buttonTitle.accept("팔로잉")
                        })
                        .disposed(by: weakself.disposeBag)
                    // 상대방을 이미 팔로우 했을 경우 유저 팔로잉 취소(언팔로우하기)
                case "팔로잉":
                    UserService.shared.unfollowUserRx(uid: (weakself.user.uid))
                        .subscribe(onNext: { _ in
                            buttonTitle.accept("팔로우")
                        })
                        .disposed(by: weakself.disposeBag)
                    // 자신의 프로필인 경우
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        // 버튼 탭할때마다 해당 유저 팔로워 변경하기
        input.followButtonTapped
            .delay(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMap { weakself, _ in
                UserService.shared.fetchFollowerUsersRx(uid: weakself.user.uid)
            }
            .withUnretained(self)
            .map { weakself, followerUsersCount in
                weakself.attributedText(withValue: followerUsersCount, text: "팔로워")
            }
            .bind(to: followerUsersCount)
            .disposed(by: disposeBag)

        
        // 버튼 탭할때 마다 해당 유저 팔로잉 변경
        input.followButtonTapped
            .delay(DispatchTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self)
            .flatMap { weakself, _ in
                UserService.shared.fetchFollowingUsersRx(uid: weakself.user.uid)
            }
            .withUnretained(self)
            .map { weakself, followingUsersCount in
                weakself.attributedText(withValue: followingUsersCount, text: "팔로잉")
            }
            .bind(to: followingUsersCount)
            .disposed(by: disposeBag)
        return Output(userTweets: userTweets,
                      buttonTitle: buttonTitle,
                      followerUsersCount: followerUsersCount,
                      followingUsersCount: followingUsersCount)
    }
    
    func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
