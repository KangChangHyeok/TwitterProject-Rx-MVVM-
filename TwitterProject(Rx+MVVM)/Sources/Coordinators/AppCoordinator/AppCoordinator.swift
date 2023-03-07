//
//  AppCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/06.
//

import UIKit

final class AppCoordinator: Coordinator, MainTabBarControllerDelegate {
    
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
    // MARK: - MainTabBarViewController Request
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
        let navigationController = AuthenticationNavigationController(rootViewController: LoginViewController())
        guard let loginViewController = navigationController.viewControllers.first as? LoginViewController else { return }
        let loginViewModel = LoginViewModel()
        loginViewController.bind(viewModel: loginViewModel)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.navigationBar.barStyle = .black
        
        mainTabBarController.present(navigationController, animated: true)
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
    }
    
    private func setChildCoordinator(append coordinator: Coordinator) {
        coordinator.start()
        childCoordinators.append(coordinator)
    }
    deinit {
        print("AppCoordinator deinit")
    }
}
