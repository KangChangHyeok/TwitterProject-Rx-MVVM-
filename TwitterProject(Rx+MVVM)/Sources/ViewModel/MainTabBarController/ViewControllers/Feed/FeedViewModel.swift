//
//  FeedViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/27.
//

import Foundation

import RxSwift
import RxCocoa
import SDWebImage

final class FeedViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let viewWillAppear = BehaviorRelay<Bool>(value: false)
    }
    // MARK: - Output
    struct Output {
        let userProfileImageUrl: Observable<URL?>
        let tweetCellModels: Observable<[TweetCellModel]>
    }
    // MARK: -
    weak var coordinator: FeedViewModelDelegate?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        let userProfileImageUrl = input.viewWillAppear
            .flatMap { _ in
            return UserService.shared.fetchUserRx()
            }.map { user in
            user.profileImageUrl
            }
        let usersTweet = input.viewWillAppear
            .flatMap { _ in
                return TweetService.shared.fetchTweetCellModels()
            }
            .map { tweetcellModels in
                tweetcellModels.forEach { tweetCellModel in
                    tweetCellModel.coordinator = self.coordinator
                }
                return tweetcellModels
            }
        
        return Output(userProfileImageUrl: userProfileImageUrl,
                      tweetCellModels: usersTweet)
    }
}
