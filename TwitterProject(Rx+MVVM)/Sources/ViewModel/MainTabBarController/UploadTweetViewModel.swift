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

protocol UploadTweetViewModelDelegate: AnyObject {
    func dismissUploadTweetViewController()
}

class UploadTweetViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let viewWillAppear = BehaviorRelay<Bool>(value: false)
        let text = PublishRelay<String>()
        let uploadTweetButtonTapped = PublishRelay<Void>()
        let cancelButtonTapped = PublishRelay<Void>()
    }
    // MARK: - Output
    struct Output {
        let userProfileImageUrl: Observable<URL?>
        let buttonTitle: Observable<String>
        let placeHolderText: Observable<String>
        let captionTextViewPlaceHolderIsHidden: Observable<Bool>
        let replyLabelIsHidden: Observable<Bool>
        let replyLabelText: BehaviorSubject<String>
    }
    // MARK: -
    weak var coordinator: UploadTweetViewModelDelegate?
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    let uploadTweetViewControllerType: UploadTweetControllerType
    
    init(type: UploadTweetControllerType) {
        self.uploadTweetViewControllerType = type
    }
    // MARK: - transform
    func transform(input: Input) -> Output {
        let userProfileImageUrl = input.viewWillAppear
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .map { user in
                user.profileImageUrl
            }
        let buttonTitle = input.viewWillAppear
            .withUnretained(self)
            .map { weakself, _ in
                switch weakself.uploadTweetViewControllerType {
                case .tweet:
                    return "Tweet"
                case .reply(_):
                    return "Reply"
                }
            }
        let placeHolderText = input.viewWillAppear
            .withUnretained(self)
            .map { weakself, _ in
                switch weakself.uploadTweetViewControllerType {
                case .tweet:
                    return "What's Happening?"
                case .reply(_):
                    return "Tweet your reply"
                }
            }
        let captionTextViewPlaceHolderIsHidden = input.text
            .map { !$0.isEmpty }
        
        let replyLabelText = BehaviorSubject<String>(value: "")
        
        let replyLabelIsHidden = input.viewWillAppear
            .withUnretained(self)
            .map { weakself, _ in
                switch weakself.uploadTweetViewControllerType {
                case .tweet:
                    return true
                case .reply(let tweet):
                    replyLabelText.onNext("\(tweet.user.userName) 에게 리트윗 보내기")
                    replyLabelText.onCompleted()
                    return false
                }
            }
        
        input.cancelButtonTapped
            .withUnretained(self)
            .bind { weakself, _ in
                weakself.coordinator?.dismissUploadTweetViewController()
            }
            .disposed(by: disposeBag)
        
        input.uploadTweetButtonTapped.withLatestFrom(input.text)
            .withUnretained(self)
            .flatMap { weakself, caption in
                TweetService.shared.uploadTweetRx(caption: caption, type: weakself.uploadTweetViewControllerType)
            }.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.coordinator?.dismissUploadTweetViewController()
            })
            .disposed(by: disposeBag)
        
        return Output(userProfileImageUrl: userProfileImageUrl,
                      buttonTitle: buttonTitle,
                      placeHolderText: placeHolderText,
                      captionTextViewPlaceHolderIsHidden: captionTextViewPlaceHolderIsHidden,
                      replyLabelIsHidden: replyLabelIsHidden,
                      replyLabelText: replyLabelText)
    }
}
