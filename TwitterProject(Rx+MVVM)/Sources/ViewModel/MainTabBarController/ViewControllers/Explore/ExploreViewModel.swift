//
//  ExploreViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/30.
//

import Foundation
import RxSwift
import RxCocoa

protocol ExploreViewModelDelegate: AnyObject {
    func pushProfileViewController(user: User)
}

final class ExploreViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let searchBarText = PublishRelay<String>()
        let userCellTapped = PublishRelay<User>()
    }
    // MARK: - Output
    struct Output {
        let usersData: PublishRelay<[User]>
    }
    // MARK: -
    weak var coordinator: ExploreViewModelDelegate?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    // MARK: - trasnform
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
        input.userCellTapped
            .withUnretained(self)
            .subscribe(onNext: { exploreViewModel, user in
                exploreViewModel.coordinator?.pushProfileViewController(user: user)
            })
            .disposed(by: disposeBag)
        return Output(usersData: usersData)
    }
}
