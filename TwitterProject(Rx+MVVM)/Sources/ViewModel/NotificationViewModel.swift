//
//  NotificationViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/06.
//

import Foundation
import RxSwift
import RxCocoa

class NotificationViewModel: ViewModelType {
    
    struct Input {
        let viewWillAppear = PublishRelay<Bool>()
    }
    struct Output {
        let notifications: Observable<[Notification]>
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    func transform(input: Input) -> Output {
        let notifications = input.viewWillAppear
            .flatMap { _ in
                NotificationService.shared.fetchNotificationRx()
            }
        return Output(notifications: notifications)
    }
}
