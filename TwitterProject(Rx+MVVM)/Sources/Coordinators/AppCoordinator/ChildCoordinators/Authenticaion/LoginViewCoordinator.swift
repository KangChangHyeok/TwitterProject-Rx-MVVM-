//
//  LoginViewCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/07.
//

import UIKit

protocol LoginViewCoordinatorDelegate: AnyObject {
    func coordinatorDidFinished(coordinator: Coordinator)
}

class LoginViewCoordinator: Coordinator {
    
    weak var appCoordinator: LoginViewCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    
    private var mainTabBarController: MainTabBarController
    private var loginNavigationController: UINavigationController?
    private var profileImagePickerController: UIImagePickerController?
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    
    func start() {
        let loginViewModel = LoginViewModel()
        let loginViewController = LoginViewController()
        loginViewController.bind(viewModel: loginViewModel)
        loginViewController.loginViewCoordinator = self
        
        self.loginNavigationController = LoginNavigationController(rootViewController: loginViewController)
        guard let navigationController = self.loginNavigationController else { return }
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.barStyle = .black
        mainTabBarController.present(navigationController, animated: true)
    }
    deinit {
        print("loginCoordinator deinit")
    }
}
// MARK: - LoginViewController Accept Request
extension LoginViewCoordinator: LoginViewControllerDelegate {
    
    func dismissLoginViewController() {
        mainTabBarController.dismiss(animated: true)
        appCoordinator?.coordinatorDidFinished(coordinator: self)
        self.childCoordinators.removeAll()
    }
    
    func showFailToastMeessageView() {
        print("로그인 실패시 토스트 메세지 뷰 출력해줘야함")
    }
    
    func showRegisterViewController() {
        let registerViewController = RegisterationViewController()
        let registerViewModel = RegisterationViewModel()
        registerViewController.bind(viewModel: registerViewModel)
        registerViewController.viewModel.coordinator = self
        self.loginNavigationController?.pushViewController(registerViewController, animated: true)
    }
}

extension LoginViewCoordinator: RegistrationViewControllerDelegate {
    func dismissRegistrationViewController() {
        self.loginNavigationController?.dismiss(animated: true)
        print("DEBUG - 회원가입 완료됨. LoginCoordinator 해제 시점")
        appCoordinator?.coordinatorDidFinished(coordinator: self)
    }
    
    func popRegistrationViewController() {
        self.loginNavigationController?.popViewController(animated: true)
    }
    
    func showImagePickerController() {
        let viewModel = ProfileImagePickerViewModel()
        viewModel.coordinator = self
        let imagePickerController = ProfileImagePickerController()
        imagePickerController.bind(viewModel: viewModel)
        
        self.loginNavigationController?.present(imagePickerController, animated: true)
        self.profileImagePickerController = imagePickerController
    
    }
}
extension LoginViewCoordinator: ProfileImagePickerViewModelDelegate {
    func didFihishPicking(image: UIImage) {
        guard let registerationViewController = loginNavigationController?.topViewController as? RegisterationViewController else { return }
        registerationViewController.viewModel.pickedImage.onNext(image)
        self.loginNavigationController?.dismiss(animated: true)
    }
}
