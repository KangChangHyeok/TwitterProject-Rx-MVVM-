//
//  ProfileViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/16.
//

import Foundation
import SDWebImage
import FirebaseAuth
import RxSwift
import RxCocoa


class ProfileViewModel: ViewModelType {
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let userTweets: Observable<[Tweet]>
        let buttonTitle: Observable<String>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        //input- viewWillAppear
        
        let userTweets = input.viewWillAppear
            .map({ [weak self] _ in
                return self?.user
            })
            .flatMap { user in
                TweetService.shared.fetchTweetsRx(user: user)
            }
        //
        let actionButtonTitle = Observable.create({ [weak self] observer in
            if Auth.auth().currentUser?.uid == self?.user.uid {
                observer.onNext("Edit Profile")
                observer.onCompleted()
            } else {
                observer.onNext("Follow")
                observer.onCompleted()
            }
            return Disposables.create()
        })
        return Output(userTweets: userTweets,
                      buttonTitle: actionButtonTitle)
    }
    
    func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedTitle.append(NSAttributedString(string: " \(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedTitle
    }
}
