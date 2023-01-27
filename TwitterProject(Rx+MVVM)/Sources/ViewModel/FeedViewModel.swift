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
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let cellProfileImageTapped = PublishRelay<Void>()
    }
    struct Output {
        let userProfileImageView: Driver<UIImageView>
        let userTweets: Observable<[Tweet]>
        let pushProfileViewController: Driver<Void>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let viewWillAppear = input.viewWillAppear.map { _ in () }.share()
        
        let userProfileImageView = viewWillAppear
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .map { user in
                let profileImageView = UIImageView()
                profileImageView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 32, height: 32))
                }
                profileImageView.layer.cornerRadius = 32 / 2
                profileImageView.layer.masksToBounds = true
                
                guard let profileImageUrl = user.profileImageUrl else { return UIImageView() }
                profileImageView.sd_setImage(with: profileImageUrl)
                return profileImageView
            }.asDriver(onErrorDriveWith: .empty())
        
        let userTweets = viewWillAppear.flatMap { _ in
            TweetService.shared.fetchTweetsRx()
        }
        
        let pushProfileViewController = input.cellProfileImageTapped.asDriver(onErrorDriveWith: .empty())
        
        
        return Output(userProfileImageView: userProfileImageView, userTweets: userTweets, pushProfileViewController: pushProfileViewController)
    }
}
