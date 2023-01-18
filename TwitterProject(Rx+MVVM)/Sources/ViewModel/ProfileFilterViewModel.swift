//
//  ProfileFilterViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/18.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileFilterViewModel: ViewModelType {
    
    struct Input {
        let profileFilterCell = PublishRelay<ProfileFilterCell>()
//        let profileFilterView = PublishRelay<ProfileFilterView>()
    }
    struct Output {
//        let profileFilterCell: Observable<ProfileFilterCell>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        return Output()
    }
        
    }

