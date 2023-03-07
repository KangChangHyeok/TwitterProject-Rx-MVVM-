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
        let userLoggedinSuccess: Driver<Void>
        let userLoggedinFailure: Driver<Void>
    }
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let isUserLoggedin = input.viewDidAppear
            .flatMap({ _ in
                AuthService.shared.checkUserLoggedin()
            })
            .share()
        
        let userLoggedinSuccess = isUserLoggedin
            .filter { $0 == true }
            .debug("성공")
            .map({ _ in
                ()
            })
            .take(1)
            .asDriver(onErrorDriveWith: .empty())
        
        let userLoggedinFailure = isUserLoggedin
            .filter { $0 == false }
            .debug("실패")
            .map({ _ in
                ()
            })
            .take(1)
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(userLoggedinSuccess: userLoggedinSuccess,
                      userLoggedinFailure: userLoggedinFailure)
    }
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
