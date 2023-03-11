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
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    // MARK: - start
    func start() {
        let exploreViewController = ExploreViewController()
        let exploreViewModel = ExploreViewModel()
        exploreViewController.bind(viewModel: exploreViewModel)
        let navigationController = makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: exploreViewController)
        mainTabBarController.viewControllers?.append(navigationController)
    }
}
