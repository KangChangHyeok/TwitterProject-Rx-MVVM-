//
//  TweetService.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/03.
//

import FirebaseDatabase
import FirebaseAuth
import RxSwift

struct TweetService {
    
    static let shared = TweetService()
    // MARK: - 트윗 업로드하기
    func uploadTweet(caption: String, type: UploadTweetControllerType, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String: Any]
        switch type {
        case .tweet:
            //tweets 카테고리에 임의의 키(tweetId)로 생성하여 각 정보를 딕셔너리 형태로 저장
            let tweetsReference = tweetsReference.childByAutoId()
            //value값 update
            tweetsReference.updateChildValues(values) { _, _ in
                guard let tweetID = tweetsReference.key else { return }
                //update 완료 후 현재 유저 아이디 값으로 ref생성후  tweet키를 저장 -> 각 유저가 생성한 모든 트윗을 추적하기 위함
                userTweetsReference.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            let values: [String: Any] = ["uid": uid,
                                         "timestamp": Int(NSDate().timeIntervalSince1970),
                                         "caption": caption,
                                         "replyingTo": tweet.user.userName]
            //해당 트윗에 대한 리트윗 레포에 트윗 id로 하위 카테고리 만들고 고유 id만들어서 저장 tweet-replies/tweetId/AutoId
            tweetRepliesReference.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values) { _, ref in
                    guard let replyKey = ref.key else { return }
                    //해당 유저가 등록한 리트윗 구분을 위해 해당 유저의 리트윗 카테코리 만들고 저장 user-replies/tweetId
                    // 아헷갈려진짜.. 벡엔드까지하려니까 개빡치네
                    userRepliesReference.child(uid).updateChildValues([tweet.tweetID: replyKey], withCompletionBlock: completion)
                }
        }
    }
    //MARK: - rx
    func uploadTweetRx(caption: String, type: UploadTweetControllerType) -> Observable<UploadTweetControllerType> {
        Observable.create { observer in
            uploadTweet(caption: caption, type: type) { error, _ in
                if let error = error {
                    observer.onError(error)
                }
                observer.onNext(type)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    // MARK: - 서버에 저장되있는 모든 트윗 가져오기
    func fetchTweets(completion: @escaping([TweetCellModel]) -> Void) {
        var tweetCellModels: [TweetCellModel] = []
        tweetsReference.observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                let tweetCellModel = TweetCellModel(tweet: tweet)
                tweetCellModels.append(tweetCellModel)
                completion(tweetCellModels)
            }
        }
    }
    // MARK: - rx
    func fetchTweetCellModels() -> Observable<[TweetCellModel]> {
        Observable.create { observer in
            fetchTweets { tweetCellModels in
                observer.onNext(tweetCellModels)
            }
            return Disposables.create()
        }
    }
    // MARK: - 해당 유저의 특정 트윗만 가져오기
    func fetchTweets(forUser user: User?, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        guard let user = user else { return }
        userTweetsReference.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            
            tweetsReference.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let tweetID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                    tweets.append(tweet)
                    completion(tweets)
                }
            }
        }
    }
    // MARK: - rx
    func fetchTweetsRx(user: User?) -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchTweets(forUser: user) { tweets in
                observer.onNext(tweets)
            }
            return Disposables.create()
        }
    }
    // MARK: - 해당 유저가 좋아요 한 트윗만 가져오기
    func fetchLikes(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        userLikesReference.child(user.uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            self.fetchTweet(withTweetID: tweetID) { likedTweet in
                tweets.append(likedTweet)
                completion(tweets)
            }
        }
    }
    // MARK: - rx
    func fetchLikesRx(user: User) -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchLikes(forUser: user) { tweets in
                observer.onNext(tweets)
            }
            return Disposables.create()
        }
    }
    // MARK: - 해당 유저의 리트윗 가져오기
    func fetchReplies(forUser user: User, completion: @escaping([Tweet]) -> Void) {
        var replies = [Tweet]()
        
        userRepliesReference.child(user.uid).observe(.childAdded) { snapshot in
            let tweetKey = snapshot.key
            guard let replyKey = snapshot.value as? String else { return }
            tweetRepliesReference.child(tweetKey).child(replyKey).observeSingleEvent(of: .value) { snapshot in
                guard let dictionary = snapshot.value as? [String: Any] else { return }
                guard let uid = dictionary["uid"] as? String else { return }
                let replyID = snapshot.key
                
                UserService.shared.fetchUser(uid: uid) { user in
                    let reply = Tweet(user: user, tweetID: replyID, dictionary: dictionary)
                    replies.append(reply)
                    completion(replies)
                }
            }
        }
    }
    // MARK: - rx
    func fetchRepliesRx(user: User) -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchReplies(forUser: user) { tweets in
                observer.onNext(tweets)
            }
            return Disposables.create()
        }
    }
    
    // MARK: - 특정 트윗 정보 가져오기
    func fetchTweet(withTweetID tweetID: String, completion: @escaping(Tweet) -> Void) {
        tweetsReference.child(tweetID).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                completion(tweet)
            }
        }
    }
    // MARK: - rx
    func fetchTweetRx(withTweetId tweetId: String) -> Observable<Tweet> {
        Observable.create { observer in
            fetchTweet(withTweetID: tweetId) { tweet in
                observer.onNext(tweet)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    // MARK: - 해당하는 트윗에 대한 리트윗 가져오기
    func fetchReplies(fortweet tweet: Tweet, completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        tweetRepliesReference.child(tweet.tweetID).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            let tweetID = snapshot.key
            UserService.shared.fetchUser(uid: uid) { user in
                let tweet = Tweet(user: user, tweetID: tweetID, dictionary: dictionary)
                tweets.append(tweet)
                completion(tweets)
            }
        }
    }
    // -rx
    func fetchRepliesRx(tweet: Tweet) -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchReplies(fortweet: tweet) { tweets in
                observer.onNext(tweets)
            }
            return Disposables.create()
        }
    }
    //트윗 좋아요
    func likeTweet(tweet: Tweet) -> Bool {
        let currentLikesCount = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        if tweet.didLike {
            tweetsReference.child("\(tweet.tweetID)").child("likesUser").child("\(currentUid)").removeValue()
            tweetsReference.child(tweet.tweetID).child("likes").setValue(currentLikesCount)
            userLikesReference.child(currentUid).child(tweet.tweetID).removeValue { _, _ in
                tweetLikesReference.child(tweet.tweetID).removeValue()
            }
            return false
        } else {
            tweetsReference.child("\(tweet.tweetID)").child("likesUser").updateChildValues(["\(currentUid)": 1])
            tweetsReference.child(tweet.tweetID).child("likes").setValue(currentLikesCount)
            userLikesReference.child(currentUid).updateChildValues([tweet.tweetID: 0]) { _, _ in
                tweetLikesReference.child(tweet.tweetID).updateChildValues([currentUid: 1])
            }
            return true
        }
    }
    func fetchTweetLikes(tweet: Tweet, completion: @escaping(Int) -> Void) {
        tweetsReference.child(tweet.tweetID).getData { error, snapshot in
            guard let dictionary = snapshot?.value as? [String:Any] else { return }
            guard let value = dictionary[tweet.tweetID] as? [String:Any] else { return }
            guard let likes = value["likes"] as? Int else { return }
            completion(likes)
        }
    }
    func fetchTweetLikesRx(tweet: Tweet) -> Observable<Int> {
        Observable.create { observer in
            fetchTweetLikes(tweet: tweet) { value in
                observer.onNext(value)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}
