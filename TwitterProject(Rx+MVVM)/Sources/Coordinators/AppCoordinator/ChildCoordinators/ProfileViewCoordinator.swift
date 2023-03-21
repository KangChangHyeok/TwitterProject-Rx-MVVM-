//
//  ProfileViewCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/20.
//

import UIKit

protocol ProfileViewCoordinatorDelegate: AnyObject {
    func coordinatorDidFinished(coordinator: Coordinator)
}

final class ProfileViewCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    weak var parentCoordinator: ProfileViewCoordinatorDelegate?
    private var navigationController: UINavigationController?
    
    let user: User
    
    init(navigationController: UINavigationController?, user: User) {
        self.navigationController = navigationController
        self.user = user
    }
    
    func start() {
        let profileViewModel = ProfileViewModel(user: user)
        profileViewModel.coordinator = self
        let profileViewController = ProfileViewController()
        profileViewController.bind(viewModel: profileViewModel)
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    deinit {
        print("ProfileViewCoordinator deinit")
    }
}

extension ProfileViewCoordinator: ProfileViewModelDelegate {
    func popProfileViewController() {
        self.navigationController?.popViewController(animated: true)
        parentCoordinator?.coordinatorDidFinished(coordinator: self)
    }
}
