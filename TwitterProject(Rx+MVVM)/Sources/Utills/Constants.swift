//
//  Constants.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/12.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase

let storageReference = Storage.storage().reference()
let profileImagesStorage = storageReference.child("profileImages")

let dataBaseReference = Database.database().reference()

let userReference = dataBaseReference.child("users")

let tweetsReference = dataBaseReference.child("tweets")

let tweetRepliesReference = dataBaseReference.child("tweet-replies")
let tweetLikesReference = dataBaseReference.child("tweet-likes")

let userTweetsReference = dataBaseReference.child("user-tweets")
let userRepliesReference = dataBaseReference.child("user-replies")
let userLikesReference = dataBaseReference.child("user-likes")
let userFollowersReference = dataBaseReference.child("user-followers")
let userFollowingReference = dataBaseReference.child("user-following")
let userLikesTweetReference = dataBaseReference.child("user-likes-forTweet")
let tweetLikesUserReference = dataBaseReference.child("tweet-likes-forUser")


let notificationReference = dataBaseReference.child("notifications")
let tweetCellIdentifier = "tweetCell"
let headerIdentifier = "ProfileHeader"
let profileFilterCellIdentifier = "ProfileFilterCell"
let userCellIdentifier = "UserCell"
let notificationCellIdentifier = "notificationCell"
let retweetCellIdentifier = "RetweetCell"
