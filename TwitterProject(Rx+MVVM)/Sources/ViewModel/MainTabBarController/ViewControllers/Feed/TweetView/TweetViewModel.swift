//
//  TweetViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import Foundation
import RxSwift
import RxCocoa

class TweetViewModel: ViewModelType {
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let repliesForTweet: Observable<[Tweet]>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    let tweet: Tweet
    var repliesForTweet: [Tweet]?
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    
    func transform(input: Input) -> Output {
        let repliesForTweet = input.viewWillAppear
            .withUnretained(self)
            .flatMap { weakself, _ in
                TweetService.shared.fetchRepliesRx(tweet: weakself.tweet)
            }
            .withUnretained(self)
            .map { weakself, tweets in
                weakself.repliesForTweet = tweets
                return tweets
            }
        return Output(repliesForTweet: repliesForTweet)
    }
    
    
    func getCaptionHeight(forwidth width: CGFloat) -> CGSize {
        let dummyLabel = UILabel()
        dummyLabel.text = tweet.caption
        dummyLabel.numberOfLines = 0
        dummyLabel.lineBreakMode = .byWordWrapping
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        dummyLabel.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
        return dummyLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    func getCellHeightForReplies(forwidth width: CGFloat, indexPath: IndexPath) -> CGSize {
        let dummyLabel = UILabel()
        dummyLabel.text = repliesForTweet?[indexPath.row].caption
        dummyLabel.numberOfLines = 0
        dummyLabel.lineBreakMode = .byWordWrapping
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        dummyLabel.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
        return dummyLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
