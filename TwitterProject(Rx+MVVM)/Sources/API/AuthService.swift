//
//  AuthService.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/12.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit
struct AuthService {
    
    static let shared = AuthService()
    
    func logInUser(email: String, password: String, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signUpUser(email: String?, password: String?, fullName: String?, userName: String?, profileImage: UIImage, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let email = email else { return }
        guard let password = password else { return }
        guard let fullName = fullName else { return }
        guard let userName = userName else { return }
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        let fileName = NSUUID().uuidString
        let stroageReference = profileImagesStorage.child(fileName)
        // storage에 profileImage 저장
        stroageReference.putData(imageData) { data, error in
            if let error = error {
                print("DEBUG - \(error.localizedDescription)")
            }
            // 저장된 profileImage Url 생성
            stroageReference.downloadURL { url, error in
                if let error = error {
                    print("DEBUG - \(error.localizedDescription)")
                }
                guard let profileImageUrl = url?.absoluteString else { return }
                // 생성된 Url과 입력받은 정보를 바탕으로 DB에 유저 정보 저장
                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("DEBUG - \(error.localizedDescription)")
                        return
                    }
                    print("DEBUG - 회원가입 성공!")
                    guard let userId = result?.user.uid else { return }
                    
                    let userValues = ["email": email,
                                      "userName": userName,
                                      "fullName": fullName,
                                      "profileImageUrl": profileImageUrl]
                    let userIdReference = userReference.child(userId)
                    userIdReference.updateChildValues(userValues, withCompletionBlock: completion)
                }
            }
        }
    }
}
