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
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let authenticationResult: Driver<Bool>
        let userData: PublishSubject<User>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let viewWillAppear = input.viewWillAppear
            .map { _ in
                ()
            }
        let authenticationResult = viewWillAppear
            .flatMap { _ in
                AuthService.shared.authenticateUserAndConfigureUIRx()
            }
            .asDriver(onErrorJustReturn: false)
        let userData = PublishSubject<User>()
        UserService.shared.fetchUserRx()
            .subscribe(onNext: { user in
                userData.onNext(user)
            })
            .disposed(by: disposeBag)
        return Output(authenticationResult: authenticationResult, userData: userData)
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
