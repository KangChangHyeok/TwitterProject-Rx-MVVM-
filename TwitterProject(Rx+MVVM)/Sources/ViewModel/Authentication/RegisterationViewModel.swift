//
//  RegisterationViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation
import RxSwift
import RxCocoa

protocol RegistrationViewControllerDelegate: AnyObject {
    func dismissRegistrationViewController()
    func popRegistrationViewController()
    func showImagePickerController()
}

final class RegisterationViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let plusPhotoButtonTapped = PublishRelay<Void>()
        let email = PublishRelay<String>()
        let password = PublishRelay<String>()
        let fullName = PublishRelay<String>()
        let userName = PublishRelay<String>()
        let signUpButtonTapped = PublishRelay<Void>()
        let loginButtonTapped = PublishRelay<Void>()
    }
    // MARK: - Output
    struct Output {
        let didFinishPicking: Driver<UIImage>
    }
    // MARK: -
    weak var coordinator: RegistrationViewControllerDelegate?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    let pickedImage = PublishSubject<UIImage>()
    // MARK: - transform
    func transform(input: Input) -> Output {
        input.plusPhotoButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { registerationViewModel, _ in
                registerationViewModel.coordinator?.showImagePickerController()
            })
            .disposed(by: disposeBag)

        let registerationInformation = Observable.combineLatest(
            pickedImage.asObservable(), input.email, input.password, input.fullName, input.userName)
            
        input.signUpButtonTapped.withLatestFrom(registerationInformation)
            .flatMap { (profileImage, email, password, fullName, userName) in
                    AuthService.shared.signUpUserRx(email: email, password: password, fullName: fullName, userName: userName, profileImage: profileImage)
            }
            .withUnretained(self)
            .subscribe(onNext: { registerationViewModel, _ in
                registerationViewModel.coordinator?.dismissRegistrationViewController()
            })
            .disposed(by: disposeBag)
    
        input.loginButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { registerationViewModel, _ in
                registerationViewModel.coordinator?.popRegistrationViewController()
            })
            .disposed(by: disposeBag)
        
        return Output(didFinishPicking: pickedImage.asDriver(onErrorDriveWith: .empty()))
    }
}
