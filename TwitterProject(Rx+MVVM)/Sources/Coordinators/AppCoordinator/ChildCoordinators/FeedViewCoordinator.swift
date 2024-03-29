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
    private var navigationController: UINavigationController?
    
    init(mainTabBarController: MainTabBarController) {
        self.mainTabBarController = mainTabBarController
    }
    // MARK: - start
    func start() {
        let feedViewController = FeedViewController()
        let feedViewModel = FeedViewModel()
        feedViewModel.coordinator = self
        feedViewController.bind(viewModel: feedViewModel)
        let navigationController = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        self.navigationController = navigationController
        mainTabBarController.viewControllers = [navigationController]
    }
}
// MARK: - FeedViewModelDelegate
extension FeedViewCoordinator: FeedViewModelDelegate {
    func pushProfileViewController(user: User) {
        let profileViewCoordinator = ProfileViewCoordinator(navigationController: navigationController, user: user)
        profileViewCoordinator.start()
        profileViewCoordinator.parentCoordinator = self
        childCoordinators.append(profileViewCoordinator)
    }
    func pushTweetViewController(tweet: Tweet) {
        let tweetViewModel = TweetViewModel(tweet: tweet)
        tweetViewModel.coordinator = self
        let tweetViewController = TweetViewController()
        tweetViewController.bind(viewModel: tweetViewModel)
        self.navigationController?.pushViewController(tweetViewController, animated: true)
    }
    func presentReTweetViewController(tweet: Tweet) {
        let uploadTweetViewModel = UploadTweetViewModel(type: .reply(tweet))
        uploadTweetViewModel.coordinator = self
        let uploadTweetViewController = UploadTweetViewController()
        uploadTweetViewController.bind(viewModel: uploadTweetViewModel)
        
        let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true)
    }
}
// MARK: - UploadTweetViewModelDelegate
extension FeedViewCoordinator: UploadTweetViewModelDelegate {
    func dismissRetweetViewController() {
        self.navigationController?.dismiss(animated: true)
    }
}
// MARK: - ProfileViewCoordinatorDelegate
extension FeedViewCoordinator: ProfileViewCoordinatorDelegate {
    func coordinatorDidFinished(coordinator: Coordinator) {
        self.childCoordinators = self.childCoordinators.filter({ $0 !== coordinator })
    }
}
