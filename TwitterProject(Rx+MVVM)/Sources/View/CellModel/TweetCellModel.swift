//
//  TweetCellModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/04.
//

import Foundation
import RxSwift
import RxCocoa

class TweetCellModel {
    
    let tweet: Tweet
    
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    struct Input {
        
    }
    struct Output {
        let captionLabelText: Observable<String>
        let informationText: Observable<NSAttributedString>
        let profileImageUrl: Driver<URL?>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let tweet = Observable.create { observer in
            observer.onNext(self.tweet)
            observer.onCompleted()
            return Disposables.create()
        }
            .share()
        
        let captionLabelText = tweet
            .map { tweet in
                tweet.caption
            }
        let informationText = tweet
            .map { tweet in
                let title = NSMutableAttributedString(string: tweet.user.fullName, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
                title.append(NSAttributedString(string: " @" + tweet.user.userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
                
                let formatter = DateComponentsFormatter()
                formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
                formatter.maximumUnitCount = 1
                formatter.unitsStyle = .abbreviated
                let now = Date()
                guard let timeStamp = formatter.string(from: tweet.timestamp, to: now) else { return NSAttributedString() }
                
                title.append(NSAttributedString(string: " ・ " + timeStamp, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
                return title as NSAttributedString
            }
        
        
        
        let profileImageUrl = tweet
            .map { tweet in
                tweet.user.profileImageUrl
            }
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(captionLabelText: captionLabelText, informationText: informationText, profileImageUrl: profileImageUrl)
    }
    
}
