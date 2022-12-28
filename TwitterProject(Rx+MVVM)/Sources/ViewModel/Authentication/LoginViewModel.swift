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
    
    var disposeBag = DisposeBag()
    
    struct Input {
        let email = BehaviorRelay(value: String())
        let password = BehaviorRelay(value: String())
        let loginButtonTapped = PublishRelay<Void>()
    }
    struct Output {
        let successLogin: Driver<Void>
        let failureLogin: Driver<Void>
    }
    let input = Input()
    lazy var output = transform(input: input)
    
    func transform(input: Input) -> Output {
        let loginResult = input.loginButtonTapped
            .withLatestFrom(Observable.combineLatest (input.email, input.password))
            .flatMap { email, password in
                AuthService.shared.logInUser(email: email, password: password)
            }
        let successLogin = loginResult
            .filter { $0 == true}
            .map { _ in
                ()
            }
            .asDriver(onErrorDriveWith: .empty())
        let failureLogin = loginResult
            .filter { $0 == false }
            .map { _ in
                ()
            }
            .asDriver(onErrorDriveWith: .empty())
        return Output(successLogin: successLogin, failureLogin: failureLogin)
    }
}
