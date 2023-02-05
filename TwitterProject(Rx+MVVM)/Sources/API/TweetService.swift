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
                .updateChildValues(values, withCompletionBlock: completion)
        }
        
    }
    
    func uploadTweetRx(caption: String, type: UploadTweetControllerType) -> Observable<Void> {
        Observable.create { observer in
            uploadTweet(caption: caption, type: type) { error, _ in
                if let error = error {
                    observer.onError(error)
                }
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    // 서버에 저장되있는 모든 트윗 가져오기
    func fetchTweets(completion: @escaping([Tweet]) -> Void) {
        var tweets = [Tweet]()
        
        tweetsReference.observe(.childAdded) { snapshot in
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
    // -rx
    func fetchTweetsRx() -> Observable<[Tweet]> {
        Observable.create { observer in
            fetchTweets { tweets in
                observer.onNext(tweets)
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
}
