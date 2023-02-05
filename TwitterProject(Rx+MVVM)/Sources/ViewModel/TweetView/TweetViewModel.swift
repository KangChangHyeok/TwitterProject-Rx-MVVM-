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
        
    }
    struct Output {
        
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    let tweet: Tweet
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    var headerTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ∙ MM/dd/yyyy"
        return formatter.string(from: tweet.timestamp)
    }
    var retweetsAtrributedString: NSAttributedString? {
        return attributedText(withValue: tweet.retweetCount, text: "Retweets")
    }
    var likesAtrributedString: NSAttributedString? {
        return attributedText(withValue: tweet.likes, text: "Likes")
    }
    func transform(input: Input) -> Output {
        return Output()
    }
    
    private func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
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
}
