//
//  Constants.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/12.
//

import Foundation
import Firebase
import FirebaseStorage

let storageReference = Storage.storage().reference()
let profileImagesStorage = storageReference.child("profileImages")

let dataBaseReference = Database.database().reference()
let userReference = dataBaseReference.child("users")
