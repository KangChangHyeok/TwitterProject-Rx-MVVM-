//
//  UploadTweetViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/02.
//

import Foundation
import RxSwift
import RxCocoa

class UploadTweetViewModel: ViewModelType {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    struct Input {
        let text = PublishRelay<String>()
        let uploadTweetButtonTapped = PublishRelay<Void>()
    }
    struct Output {
        let userData: Driver<User>
        let showCaptionTextView: Driver<Void>
        let hideCaptionTextView: Driver<Void>
        let successUploadTweet: Driver<Void>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let userData = Observable.just(self.user)
            .asDriver(onErrorDriveWith: .empty())
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
            .flatMap { caption in
                TweetService.shared.uploadTweetRx(caption: caption)
            }
            .share()
            .asDriver(onErrorDriveWith: .empty())
        
        return Output(userData: userData, showCaptionTextView: showCaptionTextView, hideCaptionTextView: hideCaptionTextView, successUploadTweet: UploadTweet)
    }
}
