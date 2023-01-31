//
//  UserService.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/26.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import RxSwift

struct UserService {
    static let shared = UserService()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        
        userReference.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    func fetchUser(completion: @escaping(User) -> Void) {
        print("DEBUG - fetchUser")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
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
    
    func fetchUsers(completion: @escaping([User]) -> Void) {
        var users = [User]()
        userReference.observe(.childAdded) { snapshot in
            let uid = snapshot.key
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let user = User(uid: uid, dictionary: dictionary)
            users.append(user)
            completion(users)
        }
    }
    
    func fetchUsersRx() -> Observable<[User]> {
        Observable.create { observer in
            fetchUsers { users in
                observer.onNext(users)
            }
            return Disposables.create()
        }
    }
    
    func followUser(uid: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        userFollowingReference.child(currentUid).updateChildValues([uid: 1]) { error, ref in
            userFollowersReference.child(uid).updateChildValues([currentUid: 1], withCompletionBlock: completion)
        }
    }
    
    func followUserRx(uid: String) -> Observable<Void> {
        Observable.create { observer in
            followUser(uid: uid) { _, _ in
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func unfollowUser(uid: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        userFollowingReference.child(currentUid).child(uid).removeValue { error, ref in
            userFollowersReference.child(uid).child(currentUid).removeValue(completionBlock: completion)
        }
    }
    func unfollowUserRx(uid: String) -> Observable<Void> {
        Observable.create { observer in
            unfollowUser(uid: uid) { _, _ in
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    //현재 접속한 유저가 다른 유저에 대해 팔로잉했는지 확인
    func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        userFollowingReference.child(currentUid).child(uid).observe(.value) { snapshot in
            completion(snapshot.exists())
        }
    }
    
    func checkIfUserIsFollowedRx(uid: String) -> Observable<Bool> {
        Observable.create { observer in
            checkIfUserIsFollowed(uid: uid) { checkIfUserIsFollowed in
                observer.onNext(checkIfUserIsFollowed)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
