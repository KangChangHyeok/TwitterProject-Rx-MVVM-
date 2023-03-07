//
//  ConversationViewCoordinator.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/03/07.
//

import UIKit

final class ConversationViewCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private var mainTabBarController: MainTabBarController
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    func start() {
        let conversationsViewController = makeNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsViewController())
        mainTabBarController.viewControllers?.append(conversationsViewController)
    }
}
