//
//  UserService.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/26.
//

import Foundation
import FirebaseAuth
import RxSwift

struct UserService {
    static let shared = UserService()
    
    func fetchUser(completion: @escaping(User) -> Void) {
        print("DEBUG - fetchUser")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        userReference.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        
        userReference.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    func fetchUserRx() -> Observable<User> {
        Observable.create { observer in
            fetchUser { user in
                observer.onNext(user)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
