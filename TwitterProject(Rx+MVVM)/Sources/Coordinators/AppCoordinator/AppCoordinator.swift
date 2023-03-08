//
//  AppCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/06.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    private var mainTabBarController: MainTabBarController
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    
    func start() {
        let viewModel = MainTabViewModel()
        mainTabBarController.bind(viewModel: viewModel)
        mainTabBarController.appCoordinator = self
    }
    deinit {
        print("AppCoordinator deinit")
    }
}
extension AppCoordinator: MainTabBarControllerDelegate {
    // MARK: - MainTabBarViewController Accept Request
    func showUploadTweetController() {
        let viewModel = UploadTweetViewModel(type: .tweet)
        let uploadTweetViewController = UploadTweetViewController()
        uploadTweetViewController.bind(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
        navigationController.modalPresentationStyle = .fullScreen
        mainTabBarController.present(navigationController, animated: true)
    }
    func showLoginViewController() {
        mainTabBarController.view.backgroundColor = .twitterBlue
        mainTabBarController.tabBar.barTintColor = .twitterBlue
        mainTabBarController.tabBar.isTranslucent = false
        let loginViewCoordinator = LoginViewCoordinator(mainTabBarController: mainTabBarController)
        loginViewCoordinator.start()
        loginViewCoordinator.appCoordinator = self
        childCoordinators.append(loginViewCoordinator)
    }
    func configureMainTabBarController() {
        mainTabBarController.view.backgroundColor = .white
        mainTabBarController.tabBar.barTintColor = .white
        mainTabBarController.tabBar.backgroundColor = .white

        let feedViewCoordinator = FeedViewCoordinator(mainTabBarController: mainTabBarController)
        setChildCoordinator(append: feedViewCoordinator)
        
        let exploreViewCoordinator = ExploreViewCoordinator(mainTabBarController: mainTabBarController)
        setChildCoordinator(append: exploreViewCoordinator)
        
        let notificationViewCoordinator = NotificationViewCoordinator(mainTabBarController: mainTabBarController)
        setChildCoordinator(append: notificationViewCoordinator)
        
        let conversationViewCoordinator = ConversationViewCoordinator(mainTabBarController: mainTabBarController)
        setChildCoordinator(append: conversationViewCoordinator)
        print(childCoordinators)
    }
    private func setChildCoordinator(append coordinator: Coordinator) {
        coordinator.start()
        childCoordinators.append(coordinator)
    }
}

extension AppCoordinator: LoginViewCoordinatorDelegate {
    func coordinatorDidFinished(coordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0 !== coordinator })
        print(childCoordinators)
    }
}
