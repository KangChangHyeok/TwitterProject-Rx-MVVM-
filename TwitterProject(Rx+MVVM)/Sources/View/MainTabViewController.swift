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
import RxViewController

class MainTabViewController: UITabBarController, ViewModelBindable {
    
    
    // MARK: - Properties
    var viewModel: MainTabViewModel!
    var disposeBag = DisposeBag()
    
    private lazy var actionButton: UIButton = { [weak self] in
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleActionButtonTapped), for: .touchUpInside)
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
    // MARK: - Selectors
    @objc func handleActionButtonTapped() {
        print("touch")
    }
    
    // MARK: - Methods
    func bindViewModel() {
        logUserOut()
        self.rx.viewDidAppear
            .bind(to: viewModel.input.viewDidAppear)
            .disposed(by: disposeBag)
        
        viewModel.output.authenticationSuccess
            .drive(onNext: { _ in
                self.configureView()
                self.configureUI()
            })
            .disposed(by: disposeBag)
        viewModel.output.authenticationFailure
            .drive(onNext: { _ in
                self.view.backgroundColor = .twitterBlue
                self.tabBar.barTintColor = .twitterBlue
                self.tabBar.isTranslucent = false
                let navigationController = UINavigationController(rootViewController: LoginViewController())
                guard var loginViewController = navigationController.viewControllers.first as? LoginViewController else { return }
                let loginViewModel = LoginViewModel()
                loginViewController.bind(viewModel: loginViewModel)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
        //user 정보 가져오면 각 viewModel input으로 넣어주기
        viewModel.output.userData
            .subscribe(onNext: { user in
                guard let navigationController = self.viewControllers?[0] as? UINavigationController else { return }
                guard var feed = navigationController.viewControllers.first as? FeedViewController else { return }
                let feedViewModel = FeedViewModel(user: user)
                feed.bind(viewModel: feedViewModel)
            })
            .disposed(by: disposeBag)
    }
    
    func makeNavigationController(image: UIImage?, rootViewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }
    func configureView() {
        tabBar.backgroundColor = .white
        let feedViewController = FeedViewController()
        print(feedViewController.isViewLoaded)
        let feedNavigationController = makeNavigationController(image: UIImage(named: "home_unselected"), rootViewController: feedViewController)
        let exploreView = makeNavigationController(image: UIImage(named: "search_unselected"), rootViewController: ExploreView())
        let notificationsView = makeNavigationController(image: UIImage(named: "like_unselected"), rootViewController: NotificationView())
        let conversationsView = makeNavigationController(image: UIImage(named: "ic_mail_outline_white_2x-1"), rootViewController: ConversationsView())
        viewControllers = [feedNavigationController, exploreView, notificationsView, conversationsView]
    }
    func configureUI() {
        view.addSubview(actionButton)
        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(tabBar.snp.top).offset(-16)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
}
