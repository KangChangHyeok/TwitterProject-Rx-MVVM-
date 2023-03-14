//
//  Tweet.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/03.
//

import Foundation
import RxDataSources
import FirebaseAuth

struct Tweet {
    let caption: String
    let tweetID: String
    let uid: String
    var likes: Int
    var timestamp: Date!
    let retweetCount: Int
    let user: User
    var didLike: Bool
    var likeButtonInitialImage: UIImage? {
        if didLike {
            return UIImage(named: "like_filled")
        } else {
            return UIImage(named: "like")
        }
    }
    var headerTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a ∙ MM/dd/yyyy"
        return formatter.string(from: self.timestamp)
    }
    var informationText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullName, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @" + user.userName, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        guard let timeStamp = formatter.string(from: timestamp, to: now) else { return NSAttributedString() }
        
        title.append(NSAttributedString(string: " ・ " + timeStamp, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return title
    }
    
    init(user: User, tweetID: String, dictionary: [String: Any]) {
        let currentUid = Auth.auth().currentUser?.uid
        self.tweetID = tweetID
        self.user = user
        self.caption = dictionary["caption"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.likes = dictionary["likes"] as? Int ?? 0
        self.retweetCount = dictionary["retweets"] as? Int ?? 0
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
        if let likesUser = dictionary["likesUser"] as? [String: Any] {
            if likesUser.filter({ return $0.key == currentUid}).isEmpty {
                self.didLike = false
            } else {
                self.didLike = true
            }
        } else {
            self.didLike = false
        }
    }
}

struct Tweets {
    var items: [Item]
}
extension Tweets: SectionModelType {
    typealias Item = Tweet
    init(original: Tweets, items: [Item]) {
        self = original
        self.items = items
    }
}




