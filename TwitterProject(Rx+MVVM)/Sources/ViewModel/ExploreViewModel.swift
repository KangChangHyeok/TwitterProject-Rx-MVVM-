//
//  ExploreViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/30.
//

import Foundation
import RxSwift
import RxCocoa

class ExploreViewModel: ViewModelType {
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let usersData: Observable<[User]>
    }
    var disposeBag = DisposeBag()
    let input = Input()
    lazy var output = transform(input: input)
    
    func transform(input: Input) -> Output {
        
        let usersData = input.viewWillAppear
            .flatMap { _ in
                UserService.shared.fetchUsersRx()
            }
            .debug("----")
        
        return Output(usersData: usersData)
    }
    
}
