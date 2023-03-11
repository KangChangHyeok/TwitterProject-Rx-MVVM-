//
//  FeedViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/27.
//

import Foundation
import SDWebImage
import RxSwift
import RxCocoa



protocol FeedViewModelDelegate: AnyObject {
    func pushProfileViewController(user: User)
}

class FeedViewModel: ViewModelType {
    
    struct Input {
        let viewWillAppear = BehaviorRelay<Bool>(value: false)
        let cellProfileImageTapped = PublishRelay<User>()
    }
    struct Output {
        let userProfileImageUrl: Driver<URL?>
        let usersTweets: Observable<[Tweet]>
//        let cellProfileImageTapped: Driver<Tweet>
//        let showRetweetViewController: Driver<Tweet>
    }
    
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    weak var coordinator: FeedViewModelDelegate?
    
    func transform(input: Input) -> Output {
        
        let userProfileImageUrl = input.viewWillAppear.flatMap { _ in
            print("DEBUG - FeedViewController-viewWillAppear 마다 유저 정보 가져오기")
            return UserService.shared.fetchUserRx()
        }.map { user in
            user.profileImageUrl
        }.asDriver(onErrorDriveWith: .empty())
        
        let usersTweet = input.viewWillAppear.flatMap { _ in
            print("DEBUG - FeedViewController-viewWillAppear 마다 모든 유저 트윗 정보 가져오기")
            return TweetService.shared.fetchTweetsRx()
        }
        input.cellProfileImageTapped
            .withUnretained(self)
            .subscribe(onNext: { feedViewModel, user in
                feedViewModel.coordinator?.pushProfileViewController(user: user)
            })
            .disposed(by: disposeBag)
//        let user = input.viewWillAppear.flatMap { _ in
//            return UserService.shared.fetchUserRx()
//        }
//
//        let userProfileImageUrl = user
//            .map { user in
//                return user.profileImageUrl
//            }.asDriver(onErrorDriveWith: .empty())
//
//        let userTweets = BehaviorRelay<[Tweet]>(value: [])
//
//        viewWillAppear.flatMap { _ in
//            TweetService.shared.fetchTweetsRx()
//        }
//        .bind(to: userTweets)
//        .disposed(by: disposeBag)
//
//        let cellProfileImageTapped = input.cellProfileImageTapped.asDriver(onErrorDriveWith: .empty())
//        let showRetweetViewController = input
//            .cellRetweetButtonTapped.asDriver(onErrorDriveWith: .empty())

        return Output(userProfileImageUrl: userProfileImageUrl,
                      usersTweets: usersTweet)
//                      cellProfileImageTapped: cellProfileImageTapped,
//                      showRetweetViewController: showRetweetViewController)
    }
}
