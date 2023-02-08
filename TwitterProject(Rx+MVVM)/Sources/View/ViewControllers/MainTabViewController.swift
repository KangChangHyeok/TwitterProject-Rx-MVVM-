//
//  MainTabView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainTabViewController: UITabBarController, ViewModelBindable {
    
    
    // MARK: - Properties
    var viewModel: MainTabViewModel!
    var disposeBag = DisposeBag()
    
    private lazy var addTweetButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        return button
    }()
    override var childForStatusBarStyle: UIViewController? {
        let selectedViewController = selectedViewController as? UINavigationController
        return selectedViewController?.topViewController
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.addSubview(addTweetButton)
        addTweetButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(tabBar.snp.top).offset(-16)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
    
    // MARK: - Methods
    func bindViewModel() {
//        viewModel.logUserOut()
        // MARK: - Input
        self.rx.viewDidAppear
            .bind(to: viewModel.input.viewDidAppear)
            .disposed(by: disposeBag)
        addTweetButton.rx.tap
            .bind(to: viewModel.input.addTweetButtonTapped)
            .disposed(by: disposeBag)
        
        // MARK: - Output
        
        // 유저 인증 성공시 화면 구성하기(최초 1회만)
        viewModel.output.configureUI
            .drive(onNext: { [weak self] userTweets in
                self?.configureViewController(userTweets: userTweets)
                
            })
            .disposed(by: disposeBag)
        
        // 유저 인증 실패(현재 로그인한 유저가 없을 경우)시 로그인 화면으로 이동
        viewModel.output.authenticationFailure
            .drive(onNext: { [weak self] _ in
                self?.view.backgroundColor = .twitterBlue
                self?.tabBar.barTintColor = .twitterBlue
                self?.tabBar.isTranslucent = false
                let navigationController = AuthenticationNavigationController(rootViewController: LoginViewController())
                guard var loginViewController = navigationController.viewControllers.first as? LoginViewController else { return }
                let loginViewModel = LoginViewModel()
                loginViewController.bind(viewModel: loginViewModel)
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.navigationBar.barStyle = .black
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
        //우측 하단 버튼 누를 경우 uploadTweetViewController화면으로 이동
        addTweetButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                let viewModel = UploadTweetViewModel(type: .tweet)
                var uploadTweetViewController = UploadTweetViewController()
                uploadTweetViewController.bind(viewModel: viewModel)
                let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func configureViewController(userTweets: [Tweet]) {
        self.view.backgroundColor = .white
        self.tabBar.barTintColor = .white
        tabBar.backgroundColor = .white
        // tabBar viewcontrollers에 들어가는 각 ViewController에 viewModel binding
        var feedViewController = FeedViewController()
        let feedViewModel = FeedViewModel(initialUserTweets: userTweets)
        feedViewController.bind(viewModel: feedViewModel)
        let feedNavigationController = viewModel.makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        
        var exploreViewController = ExploreViewController()
        let exploreViewModel = ExploreViewModel()
        exploreViewController.bind(viewModel: exploreViewModel)
        let exploreNavigationController = viewModel.makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: exploreViewController)
        
        var notificationViewController = NotificationViewController()
        let notificationViewModel = NotificationViewModel()
        notificationViewController.bind(viewModel: notificationViewModel)
        let notificationsNavigationController = viewModel.makeNavigationController(image: UIImage(named: "like_unselected"), rootViewController: notificationViewController)
        let conversationsView = viewModel.makeNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsViewController())
        viewControllers = [feedNavigationController, exploreNavigationController, notificationsNavigationController, conversationsView]
    }
}
