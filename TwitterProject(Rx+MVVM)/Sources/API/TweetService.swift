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
    
    func uploadTweet(caption: String, type: UploadTweetControllerType, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String: Any]
        switch type {
        case .tweet:
            //tweets에 해당 트윗에 대한 자동 생성 키로 구조 만들기
            let ref = tweetsReference.childByAutoId()
            //value값 update
            ref.updateChildValues(values) { error, reference in
                guard let tweetID = ref.key else { return }
                //update 완료 후 현재 유저 아이디 값으로 ref생성후  tweet키를 저장 -> 각 유저가 생성한 모든 트윗을 추적하기 위함
                userTweetsReference.child(uid).updateChildValues([tweetID: 1], withCompletionBlock: completion)
            }
        case .reply(let tweet):
            tweetRepliesReference.child(tweet.tweetID).childByAutoId()
                .updateChildValues(values) { error, ref in
                    NotificationService.shared.uploadNotification(toUser: tweet.user, type: .reply, tweetID: tweet.tweetID)
                    completion(error, ref)
                }
        }
        
    }
    
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
    // 서버에 저장되있는 모든 트윗 가져오기
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
    // -rx
    func fetchTweetCellModels() -> Observable<[TweetCellModel]> {
        Observable.create { observer in
            fetchTweets { tweetCellModels in
                observer.onNext(tweetCellModels)
            }
            return Disposables.create()
        }
    }
    
    // 해당 유저의 특정 트윗만 가져오기
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
    func fetchTweetsRx(user: User?) -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchTweets(forUser: user) { tweets in
                observer.onNext(tweets)
            }
            return Disposables.create()
        }
    }
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
    func fetchTweetRx(withTweetId tweetId: String) -> Observable<Tweet> {
        Observable.create { observer in
            fetchTweet(withTweetID: tweetId) { tweet in
                observer.onNext(tweet)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
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
    func fetchRepliesRx(tweet: Tweet) -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchReplies(fortweet: tweet) { tweets in
                observer.onNext(tweets)
            }
            return Disposables.create()
        }
    }
    func likeTweet(tweet: Tweet, completion: @escaping(Bool) -> Void) {

        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 좋아요 누른 상태인 경우 눌렀을때 좋아요 - 1, 안누른 상태일 경우 누르면 좋아요 + 1
        let likes = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1

        tweetsReference.child(tweet.tweetID).child("likes").setValue(likes)
        if tweet.didLike {
            // 유저가 해당 트윗에 이미 좋아요 눌렀을 경우
            // unlike tweet
            userLikesTweetReference.child(uid).child(tweet.tweetID).removeValue { _, _ in
                tweetLikesUserReference.child(tweet.tweetID).removeValue { _, _ in
                    completion(false)
                }
            }
        } else {
            // 유저가 해당 트윗에 좋아요 누르지 않은 경우
            userLikesTweetReference.child(uid).updateChildValues([tweet.tweetID: 0]) { _, _ in
                tweetLikesUserReference.child(tweet.tweetID).updateChildValues([uid: 1]) { _, _ in
                    completion(true)
                }
            }
        }
    }
    func likeTweet(tweet: Tweet) -> Bool {
        let currentLikesCount = tweet.didLike ? tweet.likes - 1 : tweet.likes + 1
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        if tweet.didLike {
            tweetsReference.child("\(tweet.tweetID)").child("likesUser").child("\(currentUid)").removeValue()
            tweetsReference.child(tweet.tweetID).child("likes").setValue(currentLikesCount)
            return false
        } else {
            tweetsReference.child("\(tweet.tweetID)").child("likesUser").updateChildValues(["\(currentUid)": 1])
            tweetsReference.child(tweet.tweetID).child("likes").setValue(currentLikesCount)
            return true
        }
    }
    func likeTweetRx(tweet: Tweet) -> Observable<Bool> {
        Observable.create { observer in
            likeTweet(tweet: tweet) { bool in
                observer.onNext(bool)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        
    }
    func checkIfUserLikedTweet(_ tweet: Tweet, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        userLikesTweetReference.child(uid).child(tweet.tweetID).observeSingleEvent(of: .value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func checkIfUserLiketTweetRx(tweet: Tweet) -> Observable<Bool> {
        Observable.create { observer in
            checkIfUserLikedTweet(tweet) { bool in
                observer.onNext(bool)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    func fetchTweetLikes(tweet: Tweet, completion: @escaping(Int) -> Void) {
        tweetsReference.child(tweet.tweetID).getData { error, snapshot in
            print("!!")
            guard let dictionary = snapshot?.value as? [String:Any] else { return }
            guard let value = dictionary[tweet.tweetID] as? [String:Any] else { return }
            print(value)
            guard let likes = value["likes"] as? Int else { return }
            print(likes)
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
