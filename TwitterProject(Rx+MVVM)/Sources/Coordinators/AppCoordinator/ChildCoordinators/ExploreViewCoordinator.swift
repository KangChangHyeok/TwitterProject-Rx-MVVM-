//
//  ExploreViewCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/07.
//

import UIKit

final class ExploreViewCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private var mainTabBarController: MainTabBarController
    private var navigationController: UINavigationController?
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    // MARK: - start
    func start() {
        let exploreViewController = ExploreViewController()
        let exploreViewModel = ExploreViewModel()
        exploreViewModel.coordinator = self
        exploreViewController.bind(viewModel: exploreViewModel)
        let navigationController = makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: exploreViewController)
        self.navigationController = navigationController
        mainTabBarController.viewControllers?.append(navigationController)
    }
}
// MARK: - ExploreViewModelDelegate
extension ExploreViewCoordinator: ExploreViewModelDelegate {
    func pushProfileViewController(user: User) {
        let profileViewCoordinator = ProfileViewCoordinator(navigationController: navigationController, user: user)
        profileViewCoordinator.start()
        profileViewCoordinator.parentCoordinator = self
        childCoordinators.append(profileViewCoordinator)
    }
}
// MARK: - ProfileViewCoordinatorDelegate
extension ExploreViewCoordinator: ProfileViewCoordinatorDelegate {
    func coordinatorDidFinished(coordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0 !== coordinator })
    }
}
