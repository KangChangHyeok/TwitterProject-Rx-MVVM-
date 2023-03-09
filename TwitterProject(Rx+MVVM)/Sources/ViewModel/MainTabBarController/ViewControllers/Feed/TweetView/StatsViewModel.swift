//
//  StatsViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit
import RxSwift
import RxCocoa

class StatsViewModel {
    struct Input {
        let userLikesChange = PublishRelay<Void>()
    }
    struct Output {
        let userLikesAtrributedString: BehaviorRelay<NSAttributedString>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    func transform(input: Input) -> Output {
        let userLikesAtrributedStinng = BehaviorRelay<NSAttributedString>(value: attributedText(withValue: self.tweet.likes, text: "Likes"))
        
        input.userLikesChange
            .flatMap { _ in
                TweetService.shared.fetchTweetLikesRx(tweet: self.tweet)
            }
            .map { value in
                self.attributedText(withValue: value, text: "Likes")
            }
            .bind(to: userLikesAtrributedStinng)
            .disposed(by: disposeBag)
        return Output(userLikesAtrributedString: userLikesAtrributedStinng)
    }
    let tweet: Tweet
    
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    var retweetsAtrributedString: NSAttributedString? {
        return attributedText(withValue: tweet.retweetCount, text: "Retweets")
    }
    private func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
