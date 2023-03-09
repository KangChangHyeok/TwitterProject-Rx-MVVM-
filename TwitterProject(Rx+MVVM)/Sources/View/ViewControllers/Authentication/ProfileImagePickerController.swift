//
//  ProfileImagePickerController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/08.
//

import UIKit
import RxSwift

final class ProfileImagePickerController: UIImagePickerController, ViewModelBindable {
    
    var viewModel: ProfileImagePickerViewModel!
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        
    }
    func bindViewModel() {
        self.allowsEditing = true
        // MARK: - Input
        let input = ProfileImagePickerViewModel.Input(didFihishPicking: self.rx.didFinishPickingMediaWithInfo)
        // MARK: - Output
        _ = viewModel.transform(input: input)
    }
}
