//
//  AuthService.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/12.
//

import Foundation
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import RxSwift

struct AuthService {
    
    static let shared = AuthService()
    // 유저 로그인
    func logInUser(email: String, password: String) -> Observable<Bool> {
        Observable.create { observer in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    observer.onNext(false)
                    observer.onCompleted()
                }
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    // 로그인 여부 확인
    func authenticateUserAndConfigureUIRx() -> Observable<Bool> {
        Observable<Bool>.create { observer in
            guard Auth.auth().currentUser != nil else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    //회원가입
    func signUpUser(email: String?, password: String?, fullName: String?, userName: String?, profileImage: UIImage, completion: @escaping (Error?, DatabaseReference) -> Void) {
        guard let email = email else { return }
        guard let password = password else { return }
        guard let fullName = fullName else { return }
        guard let userName = userName else { return }
        
        guard let imageData = profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let stroageReference = profileImagesStorage.child(fileName)
        
        // storage에 profileImage 저장
        stroageReference.putData(imageData) { _, error in
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
    // 회원가입 - rx
    func signUpUserRx(email: String?, password: String?, fullName: String?, userName: String?, profileImage: UIImage) -> Observable<Void> {
        Observable.create { observer in
            signUpUser(email: email, password: password, fullName: fullName, userName: userName, profileImage: profileImage) { error, _ in
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
