//
//  MainTabViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation
import RxSwift
import FirebaseAuth
import RxCocoa

class MainTabViewModel: ViewModelType {
    
    struct Input {
        let viewDidAppear = PublishRelay<Bool>()
        let addTweetButtonTapped = PublishRelay<Void>()
    }
    struct Output {
        let authenticationSuccess: Driver<Void>
        let authenticationFailure: Driver<Void>
        let userData: Observable<User>
        let showUploadTweetViewController: Driver<User>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let viewDidAppear = input.viewDidAppear.map { _ in ()}
        let authenticationResult = viewDidAppear
            .flatMap { _ in
                AuthService.shared.authenticateUserAndConfigureUIRx()
            }
            .share()
        
        let authenticationSuccess = authenticationResult
            .filter { $0 == true }
            .map({ _ in
                ()
            })
            .share()
        
        let authenticationFailure = authenticationResult
            .filter { $0 == false }
            .map({ _ in
                ()
            })
            .asDriver(onErrorDriveWith: .empty())
        
        //로그인 성공 한 경우에만 유저 정보 가져오기.
        let userData = authenticationSuccess
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .share()
        let showUploadTweetViewController = input.addTweetButtonTapped
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .asDriver(onErrorDriveWith: .empty())
            
        return Output(authenticationSuccess: authenticationSuccess.asDriver(onErrorDriveWith: .empty()), authenticationFailure: authenticationFailure, userData: userData, showUploadTweetViewController: showUploadTweetViewController)
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
