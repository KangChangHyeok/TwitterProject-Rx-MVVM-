//
//  TweetCellModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/04.
//

import UIKit
import RxSwift
import RxCocoa

final class TweetCellModel {
    // MARK: - Input
    struct Input {
        let cellProfileImageTapped = PublishRelay<Void>()
        let itemSelected = PublishRelay<Void>()
        let retweetButtonTapped = PublishRelay<Void>()
        let likeButtonTapped = PublishRelay<Void>()
    }
    // MARK: - Output
    struct Output {
        let likeButtonImage: Observable<UIImage?>
    }
    // MARK: -
    weak var coordinator: FeedViewCoordinatorType?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    var tweet: Tweet
    
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        input.cellProfileImageTapped
            .withUnretained(self)
            .subscribe(onNext: { tweetCellModel, _ in
                tweetCellModel.coordinator?.pushProfileViewController(user: tweetCellModel.tweet.user)
            })
            .disposed(by: disposeBag)
        
        input.itemSelected
            .withUnretained(self)
            .subscribe(onNext: { tweetCellModel, _ in
                tweetCellModel.coordinator?.pushTweetViewController(tweet: tweetCellModel.tweet)
            })
            .disposed(by: disposeBag)
        
        input.retweetButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { tweetCellModel, _ in
                tweetCellModel.coordinator?.presentReTweetViewController(tweet: tweetCellModel.tweet)
            })
            .disposed(by: disposeBag)
        
        let likeButtonImage = input.likeButtonTapped
            .withUnretained(self)
            .map { tweetCellModel, _ in
                if TweetService.shared.likeTweet(tweet: tweetCellModel.tweet) {
                    tweetCellModel.tweet.didLike.toggle()
                    tweetCellModel.tweet.likes += 1
                    let buttonImage = UIImage(named: "like_filled")
                    return buttonImage
                } else {
                    tweetCellModel.tweet.didLike.toggle()
                    tweetCellModel.tweet.likes -= 1
                    return UIImage(named: "like")
                }
            }
        
        return Output(likeButtonImage: likeButtonImage)
    }
    
}
