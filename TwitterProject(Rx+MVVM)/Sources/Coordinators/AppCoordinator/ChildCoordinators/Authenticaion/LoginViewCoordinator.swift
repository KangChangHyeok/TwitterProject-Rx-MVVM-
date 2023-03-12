//
//  LoginViewCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/07.
//

import UIKit

protocol LoginViewModelCoordinatorDelegate: AnyObject {
    func coordinatorDidFinished(coordinator: Coordinator)
}

final class LoginViewCoordinator: Coordinator {
    
    weak var appCoordinator: LoginViewModelCoordinatorDelegate?
    var childCoordinators: [Coordinator] = []
    
    private var mainTabBarController: MainTabBarController
    private var loginNavigationController: UINavigationController?
    private var profileImagePickerController: UIImagePickerController?
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    func start() {
        let loginViewModel = LoginViewModel()
        loginViewModel.coordinator = self
        let loginViewController = LoginViewController()
        loginViewController.bind(viewModel: loginViewModel)
        
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
    }
    func showFailToastMeessageView() {
        print("DEBUG - 로그인 실패. 실패 토스트메세지 보여줘야 하는데 아직 미구현.")
    }
    func showRegisterViewController() {
        let registerViewController = RegisterationViewController()
        let registerViewModel = RegisterationViewModel()
        registerViewController.bind(viewModel: registerViewModel)
        registerViewController.viewModel.coordinator = self
        self.loginNavigationController?.pushViewController(registerViewController, animated: true)
    }
}
// MARK: - RegistrationViewControllerDelegate
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
// MARK: - ProfileImagePickerViewModelDelegate
extension LoginViewCoordinator: ProfileImagePickerViewModelDelegate {
    func didFihishPicking(image: UIImage) {
        guard let registerationViewController = loginNavigationController?.topViewController as? RegisterationViewController else { return }
        registerationViewController.viewModel.pickedImage.onNext(image)
        self.loginNavigationController?.dismiss(animated: true)
    }
}
