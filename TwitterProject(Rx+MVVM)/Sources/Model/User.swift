//
//  User.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/26.
//

import Foundation

struct User {
    let uid: String
    var email: String
    var fullName: String
    var userName: String
    var profileImageUrl: URL?
    
    init(uid: String, dictionary: [String: AnyObject]) {
        self.uid = uid
        
        let email = dictionary["email"] as? String ?? ""
        self.email = email
        
        let fullName = dictionary["fullName"] as? String ?? ""
        self.fullName = fullName
        
        let userName = dictionary["userName"] as? String ?? ""
        self.userName = userName
        
        if let profileImageUrlString = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrlString) else { return }
            self.profileImageUrl = url
        }
    }
}
