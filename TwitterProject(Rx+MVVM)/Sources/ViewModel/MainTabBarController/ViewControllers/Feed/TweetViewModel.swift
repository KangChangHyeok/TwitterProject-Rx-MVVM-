//
//  TweetViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import Foundation
import RxSwift
import RxCocoa

final class TweetViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let retweetButtonTapped = PublishRelay<Void>()
        let likeButtonTapped = PublishRelay<Void>()
    }
    // MARK: - Output
    struct Output {
        let profileImageUrl: Observable<URL?>
        let userFullName: Observable<String>
        let userName: Observable<String>
        let caption: Observable<String>
        let date: Observable<String>
        let likeButtonImage: BehaviorRelay<UIImage?>
        let retweetCount: BehaviorRelay<NSAttributedString?>
        let likesCount: BehaviorRelay<NSAttributedString?>
        let repliesForTweet: Observable<[Tweet]>
    }
    // MARK: -
    weak var coordinator: FeedViewCoordinatorType?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    var tweet: Tweet
    var repliesForTweet: [Tweet]?
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        let tweet = input.viewWillAppear
            .withUnretained(self)
            .flatMap { tweetViewModel, _ in
                TweetService.shared.fetchTweetRx(withTweetId: tweetViewModel.tweet.tweetID)
            }
        
        let profileImageUrl = tweet.map { return $0.user.profileImageUrl }
        let userFullName = tweet.map { return $0.user.fullName }
        let userName = tweet.map { return $0.user.userName }
        let caption = tweet.map { return $0.caption }
        let date = tweet.map { return $0.headerTimeStamp }
        
        let likeButtonImage = BehaviorRelay<UIImage?>(value: nil)
        //버튼 초기 이미지 넘겨주기
        tweet.map { return $0.likeButtonInitialImage }
            .bind(to: likeButtonImage)
            .disposed(by: disposeBag)
        // 이후 버튼 탭 이벤트 발생시마다 이미지 넘겨주기
        // 스트림을 변수로 만든 이유는 리트윗, 좋아요 갯수가 tweetViewModel의 tweet에 업데이트 된 이후
        // 보내주기 위해 변수로 만들었음.
        input.likeButtonTapped
            .withUnretained(self)
            .map { tweetViewModel, _ in
                if TweetService.shared.likeTweet(tweet: tweetViewModel.tweet) {
                    tweetViewModel.tweet.didLike.toggle()
                    tweetViewModel.tweet.likes += 1
                    let buttonImage = UIImage(named: "like_filled")
                    return buttonImage
                } else {
                    tweetViewModel.tweet.didLike.toggle()
                    tweetViewModel.tweet.likes -= 1
                    return UIImage(named: "like")
                }
            }
            .bind(to: likeButtonImage)
            .disposed(by: disposeBag)
        
        let likesCount = BehaviorRelay<NSAttributedString?>(value: nil)
        //intial Value - viewWillAppear될때 초기값 보내주기
        tweet.withUnretained(self).map { tweetViewModel, tweet in
            return tweetViewModel.attributedText(withValue: tweet.likes, text: "Likes")
        }
        .bind(to: likesCount)
        .disposed(by: disposeBag)
        // likeButtonTapped 될때마다 변경된 likes 값 보내주기
        // tweet가 업데이트 된 이후 값을 보내줘야 하기 때문에 delay 사용
        input.likeButtonTapped.delay(.microseconds(5), scheduler: MainScheduler.instance).withUnretained(self)
            .map { tweetViewModel, _ in
                return tweetViewModel.attributedText(withValue: tweetViewModel.tweet.likes, text: "Likes")
            }
            .bind(to: likesCount)
            .disposed(by: disposeBag)
        
        let retweetCount = BehaviorRelay<NSAttributedString?>(value: nil)
        //inital Value- viewWillAppear될때 초기값 보내주기
        tweet.withUnretained(self).map { tweetViewModel, tweet in
            return tweetViewModel.attributedText(withValue: tweet.retweetCount, text: "Retweets")
        }
        .bind(to: retweetCount)
        .disposed(by: disposeBag)
        
        input.viewWillAppear
            .withUnretained(self)
            .flatMap { tweetViewModel, _ in
                TweetService.shared.fetchRepliesRx(tweet: tweetViewModel.tweet)
            }
            .withUnretained(self)
            .map { tweetViewModel, tweets in
                return tweetViewModel.attributedText(withValue: tweets.count, text: "Retweets")
            }
            .bind(to: retweetCount)
            .disposed(by: disposeBag)
        
        input.retweetButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { tweetViewModel, _ in
                tweetViewModel.coordinator?.presentReTweetViewController(tweet: tweetViewModel.tweet)
            })
            .disposed(by: disposeBag)
        
       let repliesForTweet = input.viewWillAppear
            .withUnretained(self)
            .flatMap { tweetViewModel, _ in
                TweetService.shared.fetchRepliesRx(tweet: tweetViewModel.tweet)
            }
            .withUnretained(self)
            .map { tweetViewModel, replies in
                tweetViewModel.repliesForTweet = replies
                return replies
            }
        
        return Output(profileImageUrl: profileImageUrl,
                      userFullName: userFullName,
                      userName: userName,
                      caption: caption,
                      date: date,
                      likeButtonImage: likeButtonImage,
                      retweetCount: retweetCount,
                      likesCount: likesCount,
                      repliesForTweet: repliesForTweet)
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
