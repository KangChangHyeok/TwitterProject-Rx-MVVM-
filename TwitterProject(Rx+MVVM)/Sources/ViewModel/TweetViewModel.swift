//
//  TweetViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import Foundation
import RxSwift
import RxCocoa

class TweetViewModel: ViewModelType {
    
    struct Input {
        
    }
    struct Output {
        
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    let tweet: Tweet
    init(tweet: Tweet) {
        self.tweet = tweet
    }
    func transform(input: Input) -> Output {
        return Output()
    }
}
