//
//  MainTabView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//
import UIKit
import SnapKit

class MainTabView: UITabBarController {
    // MARK: - Properties
    private var actionButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureUI()
    }
    // MARK: - Selectors
    @objc func handleActionButtonTapped() {
        print("touch")
    }

    // MARK: - Methods
    func makeNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }
    func configureView() {
        tabBar.backgroundColor = .white
        let feedView = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: FeedView())
        let exploreView = makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: ExploreView())
        let notificationsView = makeNavigationController(image: UIImage(named: "like_unselected"), rootViewController: NotificationView())
        let conversationsView = makeNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsView())
        viewControllers = [feedView, exploreView, notificationsView, conversationsView]
    }
    func configureUI() {
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(tabBar.snp.top).offset(16)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    
}
