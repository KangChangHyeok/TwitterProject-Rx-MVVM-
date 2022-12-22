//
//  Protocols.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/21.
//

import Foundation
import RxSwift
import UIKit

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
