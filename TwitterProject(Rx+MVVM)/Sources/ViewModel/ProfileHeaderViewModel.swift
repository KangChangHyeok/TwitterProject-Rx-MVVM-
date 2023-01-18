//
//  ProfileHeaderViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/18.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileHeaderViewModel: ViewModelType {
    
    struct Input {
        let profileFilterCell = PublishRelay<ProfileFilterCell>()
    }
    struct Output {
        let animateUnderBar: Driver<ProfileFilterCell>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let animateUnderBar = input.profileFilterCell
            .asDriver(onErrorDriveWith: .empty())
        return Output(animateUnderBar: animateUnderBar)
    }
}
