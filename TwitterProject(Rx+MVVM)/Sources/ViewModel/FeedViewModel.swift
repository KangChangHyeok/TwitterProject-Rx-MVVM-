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
        let cellProfileImageTapped = PublishRelay<Void>()
    }
    struct Output {
        let userData: Driver<User>
        let userTweets: Observable<[Tweet]>
        let pushProfileViewController: Driver<User>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let userData = Observable.just(self.user)
            .asDriver(onErrorDriveWith: .empty())
        let userTweets = TweetService.shared.fetchTweetsRx()
        
        let pushProfileViewController = input.cellProfileImageTapped
            .withUnretained(self)
            .map({ weakself, _ in
                return weakself.user
            })
            .asDriver(onErrorDriveWith: .empty())
            
        return Output(userData: userData, userTweets: userTweets, pushProfileViewController: pushProfileViewController)
    }
}
