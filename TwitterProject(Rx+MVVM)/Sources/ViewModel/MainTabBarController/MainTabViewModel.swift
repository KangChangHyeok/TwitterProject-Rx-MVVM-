//
//  MainTabViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation

import FirebaseAuth
import RxSwift
import RxCocoa

protocol MainTabViewModelDelegate: AnyObject {
    func showUploadTweetController()
    func showLoginViewController()
    func configureMainTabBarController()
}

class MainTabViewModel: ViewModelType {
    
    struct Input {
        let viewDidAppear: ControlEvent<Bool>
        let addTweetButtonTapped: ControlEvent<Void>
    }
    struct Output {
    }
    weak var appCoordinator: MainTabViewModelDelegate?
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let isUserLoggedin = input.viewDidAppear
            .flatMap({ _ in
                AuthService.shared.checkUserLoggedin()
            })
            .share()
        
        isUserLoggedin
            .filter { $0 == true }
            .take(1).asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.appCoordinator?.configureMainTabBarController()
            })
            .disposed(by: disposeBag)
        
        isUserLoggedin
            .filter { $0 == false }
            .take(1).asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.appCoordinator?.showLoginViewController()
            })
            .disposed(by: disposeBag)
        
        input.addTweetButtonTapped.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.appCoordinator?.showUploadTweetController()
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
