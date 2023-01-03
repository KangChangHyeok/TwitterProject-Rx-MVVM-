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
    
    func uploadTweet(caption: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["uid": uid,
                      "timestamp": Int(NSDate().timeIntervalSince1970),
                      "likes": 0,
                      "retweets": 0,
                      "caption": caption] as [String: Any]
        
        tweetsReference.childByAutoId().updateChildValues(values, withCompletionBlock: completion)
    }
    
    func uploadTweetRx(caption: String) -> Observable<Void> {
        Observable.create { observer in
            uploadTweet(caption: caption) { error, _ in
                if let error = error {
                    observer.onError(error)
                }
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
