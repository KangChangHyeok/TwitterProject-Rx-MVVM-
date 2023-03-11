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

// MARK: - MainTabViewModelDelegate
protocol MainTabViewModelDelegate: AnyObject {
    func presentUploadTweetController()
    func presentLoginViewController()
    func configureMainTabBarController()
}
// MARK: - MainTabViewModel
class MainTabViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let viewDidAppear = BehaviorRelay<Bool>(value: false)
        let addTweetButtonTapped = PublishRelay<Void>()
    }
    // MARK: - Output
    struct Output {
    }
    // MARK: -
    weak var appCoordinator: MainTabViewModelDelegate?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        let isUserLoggedin = input.viewDidAppear
            .filter({ $0 == true })
            .flatMap({ _ in
                AuthService.shared.checkUserLoggedin()
            })
        
        isUserLoggedin
            .filter { $0 == true }
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { mainTabViewModel, _ in
                mainTabViewModel.appCoordinator?.configureMainTabBarController()
            })
            .disposed(by: disposeBag)
        
        isUserLoggedin
            .filter { $0 == false }
            .take(1)
            .withUnretained(self)
            .subscribe(onNext: { mainTabViewModel, _ in
                mainTabViewModel.appCoordinator?.presentLoginViewController()
            })
            .disposed(by: disposeBag)
        
        input.addTweetButtonTapped
            .withUnretained(self)
            .subscribe(onNext: { mainTabViewModel, _ in
                mainTabViewModel.appCoordinator?.presentUploadTweetController()
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
