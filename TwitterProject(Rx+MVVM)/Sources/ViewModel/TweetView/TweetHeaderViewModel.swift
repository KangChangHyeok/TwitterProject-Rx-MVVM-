//
//  TweetHeaderViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/05.
//

import Foundation
import RxSwift
import RxCocoa

class TweetHeaderViewModel {
    struct Input {
        let likeButtonTapped = PublishRelay<Void>()
    }
    struct Output {
        let userLikeForTweet: Driver<Bool>
        let checkIfUserLikeTweet: Driver<Bool>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
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
    var tweet: Tweet
    
    var headerTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ∙ MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    init(tweet: Tweet) {
        self.tweet = tweet
    }
}
