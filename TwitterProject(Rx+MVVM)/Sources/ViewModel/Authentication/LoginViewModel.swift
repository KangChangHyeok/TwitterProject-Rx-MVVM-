//
//  LoginViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation
import RxSwift
import RxCocoa

protocol LoginViewControllerDelegate: AnyObject {
    func dismissLoginViewController()
    func showFailToastMeessageView()
    func showRegisterViewController()
}

class LoginViewModel: ViewModelType {
    
    weak var coordinator: LoginViewControllerDelegate?
    var disposeBag = DisposeBag()
    
    struct Input {
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let loginButtonTapped: ControlEvent<Void>
        let signUpButtonTapped: ControlEvent<Void>
    }
    struct Output {
    }
   
    func transform(input: Input) -> Output {
        let loginResult = input.loginButtonTapped
            .withLatestFrom(Observable.combineLatest (input.email, input.password))
            .flatMap { email, password in
                AuthService.shared.logInUser(email: email, password: password)
            }.share()
        
        loginResult
            .filter { $0 == true }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismissLoginViewController()
            })
            .disposed(by: disposeBag)
        
        loginResult
            .filter { $0 == false }
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showFailToastMeessageView()
            })
            .disposed(by: disposeBag)
        
        input.signUpButtonTapped.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showRegisterViewController()
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
