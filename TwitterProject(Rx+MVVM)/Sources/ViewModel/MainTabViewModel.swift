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
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let authenticationResult: Driver<Bool>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let viewWillAppear = input.viewWillAppear
            .map { _ in
                ()
            }
        let authenticationResult = viewWillAppear
            .flatMap { _ in
                self.authenticateUserAndConfigureUIRx()
                
            }
            .asDriver(onErrorJustReturn: false)
        
        return Output(authenticationResult: authenticationResult)
    }
    
    func authenticateUserAndConfigureUIRx() -> Observable<Bool> {
        Observable<Bool>.create { observer in
            guard Auth.auth().currentUser != nil else {
                observer.onNext(false)
                observer.onCompleted()
                return Disposables.create()
            }
            observer.onNext(true)
            observer.onCompleted()
            return Disposables.create()
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
