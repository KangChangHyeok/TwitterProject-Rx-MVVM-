//
//  MainTabViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/13.
//

import Foundation
import RxSwift
import FirebaseAuth

class MainTabViewModel {
    
    struct Input {
        
    }
    struct Output {
        
    }
    let input = Input()
    lazy var output = transform(input: input)
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    
    func authenticateUserAndConfigureUI(completion: @escaping (Bool) -> ()) {
        if Auth.auth().currentUser == nil  {
            completion(false)
        } else {
            completion(true)
        }
    }
    
    func logUserOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print("DEBUG - \(error.localizedDescription)")
        }
    }
}
