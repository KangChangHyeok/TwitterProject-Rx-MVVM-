//
//  FeedViewCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/07.
//

import UIKit

final class FeedViewCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    private var mainTabBarController: MainTabBarController
    private var navigationController: UINavigationController?
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    func start() {
        let feedViewController = FeedViewController()
        let feedViewModel = FeedViewModel()
        feedViewModel.coordinator = self
        feedViewController.bind(viewModel: feedViewModel)
        let navigationController = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        self.navigationController = navigationController
        mainTabBarController.viewControllers = [navigationController]
    }
}

extension FeedViewCoordinator: FeedViewModelDelegate {
    
    func pushProfileViewController(user: User) {
        let profileViewModel = ProfileViewModel(user: user)
        let profileViewController = ProfileViewController()
        profileViewController.bind(viewModel: profileViewModel)
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
}
