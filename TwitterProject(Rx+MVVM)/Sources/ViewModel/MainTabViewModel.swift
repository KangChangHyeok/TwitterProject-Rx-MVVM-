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
        let viewDidAppear: ControlEvent<Bool>
        let addTweetButtonTapped: ControlEvent<Void>
    }
    struct Output {
        let authenticationFailure: Driver<Void>
        let configureUI: Driver<[Tweet]>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let initialAuthenticationResult = AuthService.shared.authenticateUserAndConfigureUIRx()
            .take(1)
            .share()
        
        // 로그인 성공시 기본화면 설정(addTweetButton, 탭바 아이템 누를시 나오는 각 화면 설정) , 최초 1회만 실행
        
        let configureUI = initialAuthenticationResult
            .filter { $0 == true }
            .flatMap { _ in
                TweetService.shared.fetchTweetsRx()
            }
            .asDriver(onErrorDriveWith: .empty())
        
        let authenticationFailure = initialAuthenticationResult
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
    func makeNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }
}
