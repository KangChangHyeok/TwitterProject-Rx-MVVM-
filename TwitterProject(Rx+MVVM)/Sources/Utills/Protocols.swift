//
//  Protocols.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/21.
//

import Foundation
import RxSwift
import UIKit
protocol ViewModelBindable {
    associatedtype ViewModelType
    var disposeBag: DisposeBag { get set }
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

extension ViewModelBindable where Self: UIViewController {
    mutating func bind(viewModel: ViewModelType) {
        self.viewModel = viewModel
        loadViewIfNeeded()
        bindViewModel()
    }
}

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
