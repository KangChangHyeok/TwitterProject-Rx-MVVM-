//
//  TweetCellModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/04.
//

import UIKit

struct TweetCellModel {
    
    let tweet: Tweet
    
    var user: User {
        return tweet.user
    }
    var captionLabelText: String {
        return tweet.caption
    }
    var informationText: NSAttributedString {
        let title = NSMutableAttributedString(string: tweet.user.fullName, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @" + tweet.user.userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        guard let timeStamp = formatter.string(from: tweet.timestamp, to: now) else { return NSAttributedString() }
        
        title.append(NSAttributedString(string: " ・ " + timeStamp, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return title
    }
    var profileImageUrl: URL? {
        return user.profileImageUrl
    }
    init(tweet: Tweet) {
        self.tweet = tweet
    }
}
