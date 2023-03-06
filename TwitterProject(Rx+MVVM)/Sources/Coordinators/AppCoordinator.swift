//
//  AppCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/06.
//

import UIKit

class AppCoordinator: Coordinator, MainTabBarControllerDelegate {
    
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
    
    //request
    
    // MARK: - MainTabBarViewController Response
    func showUploadTweetController() {
        let viewModel = UploadTweetViewModel(type: .tweet)
        var uploadTweetViewController = UploadTweetViewController()
        uploadTweetViewController.bind(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
        navigationController.modalPresentationStyle = .fullScreen
        mainTabBarController.present(navigationController, animated: true)
    }
    
    func showLoginViewController() {
        
    }
    deinit {
        print("AppCoordinator deinit")
    }
}
