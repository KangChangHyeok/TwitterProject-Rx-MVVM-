//
//  NotificationCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/07.
//

import UIKit

final class NotificationViewCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private var mainTabBarController: MainTabBarController
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    // MARK: - start
    func start() {
        let notificationViewController = NotificationViewController()
        let notificationViewModel = NotificationViewModel()
        notificationViewController.bind(viewModel: notificationViewModel)
        let navigationController = makeNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notificationViewController)
        mainTabBarController.viewControllers?.append(navigationController)
    }
}
