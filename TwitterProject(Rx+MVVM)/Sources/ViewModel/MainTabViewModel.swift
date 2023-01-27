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
        let authenticationFailure: Driver<Void>
        let configureUI: Driver<Void>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let authenticationResult = input.viewDidAppear.map { _ in ()}
            .flatMap { _ in
                AuthService.shared.authenticateUserAndConfigureUIRx()
            }
            .share()
        
        // 로그인 성공시 기본화면 설정(addTweetButton, 탭바 아이템 누를시 나오는 각 화면 설정) , 최초 1회만 실행
        
        let configureUI = authenticationResult
            .filter { $0 == true }
            .map({ _ in
                ()
            })
            .share()
            .take(1).asDriver(onErrorDriveWith: .empty())
        
        let authenticationFailure = authenticationResult
            .filter { $0 == false }
            .map({ _ in
                ()
            })
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(authenticationFailure: authenticationFailure,
                      configureUI: configureUI)
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
