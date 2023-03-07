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
    func configureMainTabBarController(userTweets: [Tweet]) {
        mainTabBarController.view.backgroundColor = .white
        mainTabBarController.tabBar.barTintColor = .white
        mainTabBarController.tabBar.backgroundColor = .white
        // tabBar viewcontrollers에 들어가는 각 ViewController에 viewModel binding
        let feedViewController = FeedViewController()
        let feedViewModel = FeedViewModel(initialUserTweets: userTweets)
        feedViewController.bind(viewModel: feedViewModel)
        let feedNavigationController = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        
        let exploreViewController = ExploreViewController()
        let exploreViewModel = ExploreViewModel()
        exploreViewController.bind(viewModel: exploreViewModel)
        let exploreNavigationController = makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: exploreViewController)
        
        let notificationViewController = NotificationViewController()
        let notificationViewModel = NotificationViewModel()
        notificationViewController.bind(viewModel: notificationViewModel)
        let notificationsNavigationController = makeNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notificationViewController)
        let conversationsView = makeNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsViewController())
        mainTabBarController.viewControllers = [feedNavigationController, exploreNavigationController, notificationsNavigationController, conversationsView]
    }
    private func makeNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }
    deinit {
        print("AppCoordinator deinit")
    }
}
