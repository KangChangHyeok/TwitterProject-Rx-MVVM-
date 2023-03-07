//
//  LoginViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelType {
    
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let loginButtonTapped: ControlEvent<Void>
    }
    struct Output {
        let userLoginSucceed: Driver<Void>
        let userLoginFailed: Driver<Void>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let loginResult = input.loginButtonTapped
            .withLatestFrom(Observable.combineLatest (input.email, input.password))
            .flatMap { email, password in
                AuthService.shared.logInUser(email: email, password: password)
            }.share()
        
        let userLoginSucceed = loginResult
            .filter { $0 == true }
            .map { _ in
                ()
            }
            .asDriver(onErrorDriveWith: .empty())
        let userLoginFailed = loginResult
            .filter { $0 == false }
            .map { _ in
                ()
            }
            .asDriver(onErrorDriveWith: .empty())
        return Output(userLoginSucceed: userLoginSucceed,
                      userLoginFailed: userLoginFailed)
    }
}
