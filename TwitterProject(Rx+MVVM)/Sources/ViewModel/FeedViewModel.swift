//
//  FeedViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/27.
//

import Foundation
import SDWebImage
import RxSwift
import RxCocoa

class FeedViewModel: ViewModelType {
    
    var initialUserTweets: [Tweet]
    
    init(initialUserTweets: [Tweet]) {
        self.initialUserTweets = initialUserTweets
    }
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let cellProfileImageTapped = PublishRelay<User>()
        let cellRetweetButtonTapped = PublishRelay<Tweet>()
    }
    struct Output {
        let userProfileImageUrl: Driver<URL?>
        let userTweets: BehaviorRelay<[Tweet]>
        let cellProfileImageTapped: Driver<User>
        let showRetweetViewController: Driver<Tweet>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let viewWillAppear = input.viewWillAppear.map { _ in () }.share()
        
        let user = viewWillAppear.flatMap { _ in
            return UserService.shared.fetchUserRx()
        }
        
        let userProfileImageUrl = user
            .map { user in
                return user.profileImageUrl
            }.asDriver(onErrorDriveWith: .empty())
        
        let userTweets = BehaviorRelay<[Tweet]>(value: initialUserTweets)
        
        viewWillAppear.flatMap { _ in
            TweetService.shared.fetchTweetsRx()
        }
        .withUnretained(self)
        .map({ weakself, userTweets in
            weakself.initialUserTweets = userTweets
            return userTweets
        })
        .bind(to: userTweets)
        .disposed(by: disposeBag)
        
        let cellProfileImageTapped = input.cellProfileImageTapped.asDriver(onErrorDriveWith: .empty())
        let showRetweetViewController = input
            .cellRetweetButtonTapped.asDriver(onErrorDriveWith: .empty())

        return Output(userProfileImageUrl: userProfileImageUrl,
                      userTweets: userTweets,
                      cellProfileImageTapped: cellProfileImageTapped,
                      showRetweetViewController: showRetweetViewController)
    }
    
    func getCellHeight(forwidth width: CGFloat, indexPath: IndexPath) -> CGSize {
        let dummyLabel = UILabel()
        dummyLabel.text = initialUserTweets[indexPath.row].caption
        dummyLabel.numberOfLines = 0
        dummyLabel.lineBreakMode = .byWordWrapping
        dummyLabel.translatesAutoresizingMaskIntoConstraints = false
        dummyLabel.snp.makeConstraints { make in
            make.width.equalTo(width)
        }
        return dummyLabel.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
