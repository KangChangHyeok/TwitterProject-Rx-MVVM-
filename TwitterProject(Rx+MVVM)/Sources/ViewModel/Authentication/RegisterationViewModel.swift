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
    //회원가입이 종료되는거
    func dismissRegistrationViewController()
    // 하단 버튼 눌러서 로그인 화면으로 돌아가기
    func popRegistrationViewController()
    func showImagePickerController()
}

class RegisterationViewModel: ViewModelType {
    
    weak var coordinator: RegistrationViewControllerDelegate?
    var disposeBag = DisposeBag()
    
    struct Input {
        let plusPhotoButtonTapped: ControlEvent<Void>
        let email: ControlProperty<String>
        let password: ControlProperty<String>
        let fullName: ControlProperty<String>
        let userName: ControlProperty<String>
        let signUpButtonTapped: ControlEvent<Void>
        let loginButtonTapped: ControlEvent<Void>
    }
    
    let pickedImage = PublishSubject<UIImage>()
    struct Output {
        let didFinishPicking: Driver<UIImage>
    }
    
    func transform(input: Input) -> Output {
        input.plusPhotoButtonTapped.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.showImagePickerController()
            })
            .disposed(by: disposeBag)

        let registerationInformation = Observable.combineLatest(pickedImage.asObservable(),input.email, input.password, input.fullName, input.userName)
            
        let signUpRequest = input.signUpButtonTapped.withLatestFrom(registerationInformation)
            .flatMap { (profileImage, email, password, fullName, userName) in
                    AuthService.shared.signUpUserRx(email: email, password: password, fullName: fullName, userName: userName, profileImage: profileImage)
            }
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismissRegistrationViewController()
            })
            .disposed(by: disposeBag)
    
        input.loginButtonTapped.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.popRegistrationViewController()
            })
            .disposed(by: disposeBag)
        return Output(didFinishPicking: pickedImage.asDriver(onErrorDriveWith: .empty()))
    }
}
