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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - API
    func logUserOut() {
        viewModel.logUserOut()
    }
    // MARK: - Methods
    func bindViewModel() {
//        logUserOut()
        // MARK: - Input
        self.rx.viewDidAppear
            .bind(to: viewModel.input.viewDidAppear)
            .disposed(by: disposeBag)
        addTweetButton.rx.tap
            .bind(to: viewModel.input.addTweetButtonTapped)
            .disposed(by: disposeBag)
        
        // MARK: - Output
        
        // 유저 인증 성공시 화면 구성하기
        viewModel.output.configureUI
            .drive(onNext: { [weak self] _ in
                self?.configureView()
                self?.configureUI()
            })
            .disposed(by: disposeBag)
        // 유저 인증 실패(현재 로그인한 유저가 없을 경우)시 로그인 화면으로 이동
        viewModel.output.authenticationFailure
            .drive(onNext: { [weak self] _ in
                self?.view.backgroundColor = .twitterBlue
                self?.tabBar.barTintColor = .twitterBlue
                self?.tabBar.isTranslucent = false
                let navigationController = UINavigationController(rootViewController: LoginViewController())
                guard var loginViewController = navigationController.viewControllers.first as? LoginViewController else { return }
                let loginViewModel = LoginViewModel()
                loginViewController.bind(viewModel: loginViewModel)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
        //user 정보 가져오면 각 viewModel input으로 넣어주기
        viewModel.output.userData
            .subscribe(onNext: { [weak self] user in
                guard let navigationController = self?.viewControllers?[0] as? UINavigationController else { return }
                guard var feed = navigationController.viewControllers.first as? FeedViewController else { return }
                feed.collectionView.dataSource = nil
                feed.collectionView.delegate = nil
                let feedViewModel = FeedViewModel(user: user)
                feed.bind(viewModel: feedViewModel)
            })
            .disposed(by: disposeBag)
        viewModel.output.showUploadTweetViewController
            .drive(onNext: { [weak self] user in
                let viewModel = UploadTweetViewModel(user: user)
                var uploadTweetViewController = UploadTweetViewController()
                uploadTweetViewController.bind(viewModel: viewModel)
                let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
                navigationController.modalPresentationStyle = .fullScreen
                self?.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func makeNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }
    //앱 실행시 초기 한번만 실행 - (take(1))
    func configureView() {
        self.view.backgroundColor = .white
        self.tabBar.barTintColor = .white
        tabBar.backgroundColor = .white
        let feedViewController = FeedViewController()
        let feedNavigationController = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        let exploreView = makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: ExploreViewController())
        let notificationsView = makeNavigationController(image: UIImage(named: "like_unselected"), rootViewController: NotificationViewController())
        let conversationsView = makeNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsViewController())
        viewControllers = [feedNavigationController, exploreView, notificationsView, conversationsView]
    }
    func configureUI() {
        view.addSubview(addTweetButton)
        addTweetButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(tabBar.snp.top).offset(-16)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
}
