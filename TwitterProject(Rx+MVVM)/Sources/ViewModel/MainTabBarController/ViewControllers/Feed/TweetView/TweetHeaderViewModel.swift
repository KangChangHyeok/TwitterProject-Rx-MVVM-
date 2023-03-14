//
//  TweetHeaderViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/05.
//

import Foundation

import RxSwift
import RxCocoa

final class TweetHeaderViewModel {
    // MARK: - Input
    struct Input {
        let likeButtonTapped = PublishRelay<Void>()
    }
    // MARK: - Output
    struct Output {
        let userLikeForTweet: Driver<Bool>
        let checkIfUserLikeTweet: Driver<Bool>
    }
    // MARK: -
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    // MARK: -
    var tweet: Tweet
    
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    // MARK: - transform
    func transform(input: Input) -> Output {
        let userLikeForTweet = input.likeButtonTapped
            .flatMap { _ in
                TweetService.shared.likeTweetRx(tweet: self.tweet)
            }
            .map { bool in
                self.tweet.didLike = bool
                if bool {
                    self.tweet.likes += 1
                } else {
                    self.tweet.likes -= 1
                }
                return bool
            }.asDriver(onErrorDriveWith: .empty())
        
        let checkIfUserLikeTweet = TweetService.shared.checkIfUserLiketTweetRx(tweet: self.tweet)
            .map({ bool in
                self.tweet.didLike = bool
                return bool
            })
            .asDriver(onErrorDriveWith: .empty())
        return Output(userLikeForTweet: userLikeForTweet,
                      checkIfUserLikeTweet: checkIfUserLikeTweet)
    }
}
