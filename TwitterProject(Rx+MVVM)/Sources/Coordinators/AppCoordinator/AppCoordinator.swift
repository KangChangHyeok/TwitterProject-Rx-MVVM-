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
        viewModel.appCoordinator = self
        mainTabBarController.bind(viewModel: viewModel)
    }
    deinit {
        print("DEBUG - 앱 종료. AppCoordinator deinit")
    }
}
extension AppCoordinator: MainTabViewModelDelegate {
    func presentUploadTweetController() {
        let viewModel = UploadTweetViewModel(type: .tweet)
        viewModel.coordinator = self
        let uploadTweetViewController = UploadTweetViewController()
        uploadTweetViewController.bind(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
        navigationController.modalPresentationStyle = .fullScreen
        mainTabBarController.present(navigationController, animated: true)
        print("DEBUG - 트위터 추가 버튼 클릭. 트위터 등록 화면 출력.")
    }
    func presentLoginViewController() {
        mainTabBarController.view.backgroundColor = .twitterBlue
        mainTabBarController.tabBar.barTintColor = .twitterBlue
        mainTabBarController.tabBar.isTranslucent = false
        let loginViewCoordinator = LoginViewCoordinator(mainTabBarController: mainTabBarController)
        loginViewCoordinator.start()
        loginViewCoordinator.appCoordinator = self
        childCoordinators.append(loginViewCoordinator)
        print("DEBUG - 유저 로그인 하지 않음 로그인 화면 출력 childCoordinators: \(childCoordinators)")
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
        print("DEBUG - 로그인 완료 이후 탭별로 각 화면 코디네이터 생성 childCoordinators: \(childCoordinators)")
    }
    private func setChildCoordinator(append coordinator: Coordinator) {
        coordinator.start()
        childCoordinators.append(coordinator)
    }
}

extension AppCoordinator: LoginViewCoordinatorDelegate {
    func coordinatorDidFinished(coordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0 !== coordinator })
        print("DEBUG - 로그인 완료(회원가입 성공 or 로그인 화면에서 로그인 성공) 현재 childCoordinators: \(childCoordinators)")
    }
}
extension AppCoordinator: UploadTweetViewModelDelegate {
    func dismissUploadTweetViewController() {
        mainTabBarController.dismiss(animated: true)
    }
}
