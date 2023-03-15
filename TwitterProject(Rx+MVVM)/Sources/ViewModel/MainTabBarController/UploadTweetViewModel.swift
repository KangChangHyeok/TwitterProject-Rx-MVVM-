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

@objc protocol UploadTweetViewModelDelegate: AnyObject {
    @objc optional func dismissUploadTweetViewController()
    @objc optional func dismissRetweetViewController()
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
        let captionText: Observable<String>
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
            .filter({ $0 == true })
            .flatMap { _ in
                UserService.shared.fetchUserRx()
            }
            .map { user in
                user.profileImageUrl
            }
        let buttonTitle = input.viewWillAppear
            .filter({ $0 == true })
            .withUnretained(self)
            .map { weakself, _ in
                switch weakself.uploadTweetViewControllerType {
                case .tweet:
                    return "트윗"
                case .reply(_):
                    return "리트윗"
                }
            }
        let placeHolderText = input.viewWillAppear
            .filter({ $0 == true })
            .withUnretained(self)
            .map { weakself, _ in
                switch weakself.uploadTweetViewControllerType {
                case .tweet:
                    return "트윗을 남겨주세요!(최대 30자)"
                case .reply(_):
                    return "리트윗을 남겨주세요!(최대 30자)"
                }
            }
        let captionTextViewPlaceHolderIsHidden = input.text
            .map { !$0.isEmpty }
        
        let replyLabelText = BehaviorSubject<String>(value: "")
        
        let replyLabelIsHidden = input.viewWillAppear
            .filter({ $0 == true })
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
            .bind { uploadTweetViewModel, _ in
                switch uploadTweetViewModel.uploadTweetViewControllerType {
                case .tweet:
                    uploadTweetViewModel.coordinator?.dismissUploadTweetViewController?()
                case .reply(_):
                    uploadTweetViewModel.coordinator?.dismissRetweetViewController?()
                }
            }
            .disposed(by: disposeBag)

        let captionText = input.text
            .filter { captionText in
                return captionText.count >= 30
            }
            .map { string in
                let index = string.index(string.startIndex, offsetBy: 30)
                return String(string[..<index])
            }
            
            
        
        input.uploadTweetButtonTapped.withLatestFrom(input.text)
            .withUnretained(self)
            .flatMap { uploadTweetViewModel, caption in
                TweetService.shared.uploadTweetRx(caption: caption, type: uploadTweetViewModel.uploadTweetViewControllerType)
            }
            .withUnretained(self)
            .subscribe(onNext: { uploadTweetViewModel, type in
                switch type {
                case .tweet:
                    uploadTweetViewModel.coordinator?.dismissUploadTweetViewController?()
                case .reply(_):
                    uploadTweetViewModel.coordinator?.dismissRetweetViewController?()
                }
            })
            .disposed(by: disposeBag)
        
        return Output(userProfileImageUrl: userProfileImageUrl,
                      buttonTitle: buttonTitle,
                      placeHolderText: placeHolderText,
                      captionTextViewPlaceHolderIsHidden: captionTextViewPlaceHolderIsHidden,
                      replyLabelIsHidden: replyLabelIsHidden,
                      replyLabelText: replyLabelText, captionText: captionText)
    }
}
