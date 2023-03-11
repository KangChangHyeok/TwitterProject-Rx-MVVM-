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
        let searchBarText = PublishRelay<String>()
    }
    struct Output {
        let usersData: PublishRelay<[User]>
    }
    var disposeBag = DisposeBag()
    
    let input = Input()
    lazy var output = transform(input: input)
    
    func transform(input: Input) -> Output {
        var initalUsersData: [User] = []
        let usersData = PublishRelay<[User]>()
        
        input.viewWillAppear
            .flatMap { _ in
                UserService.shared.fetchUsersRx()
            }
            .bind { users in
                initalUsersData = users
                usersData.accept(users)
            }
            .disposed(by: disposeBag)
        
        input.searchBarText
            .map { text -> [User] in
                if text.isEmpty {
                    return initalUsersData
                } else {
                    let result = initalUsersData.filter { $0.fullName.contains(text) }
                    return result
                }
            }
            .bind(to: usersData)
            .disposed(by: disposeBag)
        
        return Output(usersData: usersData)
    }
    
}
