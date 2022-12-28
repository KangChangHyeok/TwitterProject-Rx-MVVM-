//
//  FeedViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/27.
//

import Foundation
import RxSwift
import RxCocoa

class FeedViewModel: ViewModelType {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    struct Input {
        let userData = PublishRelay<User>()
    }
    struct Output {
        let user: Driver<User>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let user = input.userData
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(user: user)
    }
}
