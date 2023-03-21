//
//  NotificationService.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/06.
//

import Foundation
import FirebaseAuth
import RxSwift

struct NotificationService {
    static let shared = NotificationService()
    
    func uploadNotification(toUser user: User, type: NotificationType, tweetID: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "uid": uid,
                                     "type": type.rawValue]
        if let tweetID = tweetID {
            values["tweetID"] = tweetID
            
        }
        notificationReference.child(user.uid).childByAutoId().updateChildValues(values)
    }
    
    func fetchNotification(completion: @escaping([Notification]) -> Void) {
        var notifications = [Notification]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        notificationReference.child(uid).observe(.childAdded) { snapshot in
            guard let dictionary = snapshot.value as? [String:AnyObject] else { return }
            guard let uid = dictionary["uid"] as? String else { return }
            
            UserService.shared.fetchUser(uid: uid) { user in
                let notification = Notification(user: user, dictionary: dictionary)
                notifications.append(notification)
                completion(notifications)
            }
        }
    }
    func fetchNotificationRx() -> Observable<[Notification]> {
        Observable.create { observer in
            fetchNotification { notifications in
                observer.onNext(notifications)
            }
            return Disposables.create()
        }
    }
}
