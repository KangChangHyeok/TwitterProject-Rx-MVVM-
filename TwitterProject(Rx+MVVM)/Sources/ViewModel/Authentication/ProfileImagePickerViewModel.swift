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

final class ProfileImagePickerViewModel: ViewModelType {
    // MARK: - Input
    struct Input {
        let didFihishPicking: Observable<[UIImagePickerController.InfoKey : AnyObject]>
    }
    // MARK: - Output
    struct Output {
    }
    // MARK: -
    weak var coordinator: ProfileImagePickerViewModelDelegate?
    var disposeBag = DisposeBag()
    // MARK: - transform
    func transform(input: Input) -> Output {
        
        input.didFihishPicking
            .withUnretained(self)
            .subscribe(onNext: { profileImagePickerViewModel, information in
                guard let pickedImage = information[.editedImage] as? UIImage else { return }
                profileImagePickerViewModel.coordinator?.didFihishPicking(image: pickedImage)
            })
            .disposed(by: disposeBag)
        return Output()
    }
}
