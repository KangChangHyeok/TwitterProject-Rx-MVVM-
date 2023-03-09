//
//  ProfileImageViewModel.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/08.
//

import Foundation
import RxSwift

protocol ProfileImagePickerViewModelDelegate: AnyObject {
    func didFihishPicking(image: UIImage)
}

class ProfileImagePickerViewModel: ViewModelType {
    
    weak var coordinator: ProfileImagePickerViewModelDelegate?
    var disposeBag = DisposeBag()
    
    struct Input {
        let didFihishPicking: Observable<[UIImagePickerController.InfoKey : AnyObject]>
    }
    struct Output {
    }
    
    func transform(input: Input) -> Output {
        
        input.didFihishPicking
            .withUnretained(self)
            .subscribe(onNext: { weakself, information in
                guard let pickedImage = information[.editedImage] as? UIImage else { return }
                weakself.coordinator?.didFihishPicking(image: pickedImage)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
