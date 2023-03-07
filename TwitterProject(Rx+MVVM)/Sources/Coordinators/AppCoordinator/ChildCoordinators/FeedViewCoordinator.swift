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
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    func start() {
        let feedViewController = FeedViewController()
        let feedViewModel = FeedViewModel()
        feedViewController.bind(viewModel: feedViewModel)
        let navigationController = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        mainTabBarController.viewControllers = [navigationController]
    }
    
}
