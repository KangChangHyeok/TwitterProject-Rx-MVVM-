//
//  UploadTweetViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/02.
//

import Foundation
import SDWebImage
import RxSwift
import RxCocoa

enum UploadTweetControllerType {
    case tweet
    case reply(Tweet)
}

class UploadTweetViewModel: ViewModelType {
    let uploadTweetViewControllerType: UploadTweetControllerType
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
        let text = PublishRelay<String>()
        let uploadTweetButtonTapped = PublishRelay<Void>()
    }
    struct Output {
        let userProfileImageUrl: Observable<URL?>
        let showCaptionTextView: Driver<Void>
        let hideCaptionTextView: Driver<Void>
        let successUploadTweet: Driver<Void>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    var buttonTitle: String
    var palceHolderText: String
    
    init(type: UploadTweetControllerType) {
        self.uploadTweetViewControllerType = type
        switch uploadTweetViewControllerType {
        case .tweet:
            buttonTitle = "Tweet"
            palceHolderText = "What's Happening?"
        case .reply(let tweet):
            buttonTitle = "Reply"
            palceHolderText = "Tweet your reply"
        }
    }
    
    func transform(input: Input) -> Output {
        
        let userProfileImageUrl = input.viewWillAppear
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .map { user in
                user.profileImageUrl
            }
        
        let showCaptionTextView = input.text
            .filter { $0.isEmpty == true }
            .map { _ in
                ()
            }
            .asDriver(onErrorDriveWith: .empty())
        let hideCaptionTextView = input.text
            .filter { $0.isEmpty == false }
            .map { _ in
                ()
            }
            .asDriver(onErrorDriveWith: .empty())
        let UploadTweet = input.uploadTweetButtonTapped.withLatestFrom(input.text)
            .withUnretained(self)
            .flatMap { weakself, caption in
                TweetService.shared.uploadTweetRx(caption: caption, type: weakself.uploadTweetViewControllerType)
            }
            .share()
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(userProfileImageUrl: userProfileImageUrl,
                      showCaptionTextView: showCaptionTextView,
                      hideCaptionTextView: hideCaptionTextView,
                      successUploadTweet: UploadTweet)
    }
}
