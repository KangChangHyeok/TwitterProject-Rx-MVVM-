//
//  RegisterationViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation
import RxSwift
import RxCocoa

class RegisterationViewModel: ViewModelType {
    
    struct Input {
        let profileImage = PublishRelay<UIImage>()
        let email = PublishRelay<String>()
        let password = PublishRelay<String>()
        let fullName = PublishRelay<String>()
        let userName = PublishRelay<String>()
        let signUpButtonTapped = PublishRelay<Void>()
    }
    struct Output {
        let signUpRequest: Driver<Void>
    }
    
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    func transform(input: Input) -> Output {
        let userInformation = Observable.combineLatest(input.profileImage, input.email, input.password, input.fullName, input.userName)
        
        let signUpRequest = input.signUpButtonTapped.withLatestFrom(userInformation)
            .flatMap { (profileImage, email, password, fullName, userName) in
                    AuthService.shared.signUpUserRx(email: email, password: password, fullName: fullName, userName: userName, profileImage: profileImage)
            }
            .asDriver(onErrorJustReturn: ())
    
        return Output(signUpRequest: signUpRequest)
    }
}
