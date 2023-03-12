//
//  FeedViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/27.
//

import Foundation

import RxSwift
import RxCocoa
import SDWebImage

protocol FeedViewModelDelegate: AnyObject {
    func pushProfileViewController(user: User)
    func pushTweetViewController(tweet: Tweet)
    func presentReTweetViewController(tweet: Tweet)
}

final class FeedViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let viewWillAppear = BehaviorRelay<Bool>(value: false)
        let cellProfileImageTapped = PublishRelay<User>()
        let itemSelected = PublishRelay<Tweet>()
        let retweetButtonTapped = PublishRelay<Tweet>()
    }
    // MARK: - Output
    struct Output {
        let userProfileImageUrl: Observable<URL?>
        let usersTweets: Observable<[Tweet]>
    }
    // MARK: -
    weak var coordinator: FeedViewModelDelegate?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        let userProfileImageUrl = input.viewWillAppear.flatMap { _ in
            print("DEBUG - FeedViewController-viewWillAppear 마다 유저 정보 가져오기")
            return UserService.shared.fetchUserRx()
        }.map { user in
            user.profileImageUrl
        }
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
        
        input.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { feedViewModel, tweet in
                feedViewModel.coordinator?.pushTweetViewController(tweet: tweet)
            })
            .disposed(by: disposeBag)
        
        input.retweetButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { feedViewModel, tweet in
                feedViewModel.coordinator?.presentReTweetViewController(tweet: tweet)
            })
            .disposed(by: disposeBag)

        return Output(userProfileImageUrl: userProfileImageUrl,
                      usersTweets: usersTweet)
    }
}
