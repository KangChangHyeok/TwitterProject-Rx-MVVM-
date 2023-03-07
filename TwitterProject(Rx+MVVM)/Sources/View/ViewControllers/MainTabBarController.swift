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

protocol MainTabBarControllerDelegate: AnyObject {
    func showUploadTweetController()
    func showLoginViewController()
    func configureMainTabBarController()
}

final class MainTabBarController: UITabBarController, ViewModelBindable {
    
    // MARK: - Properties
    weak var appCoordinator: MainTabBarControllerDelegate?
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
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        viewModel.logUserOut()
        // MARK: - Input
        let input = MainTabViewModel.Input(viewDidAppear: self.rx.viewDidAppear,
                                           addTweetButtonTapped: addTweetButton.rx.tap)
        // MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.userLoggedinSuccess
            .drive(onNext: { [weak self] userTweets in
                self?.appCoordinator?.configureMainTabBarController()
            })
            .disposed(by: disposeBag)
        
        output.userLoggedinFailure
            .drive(onNext: { [weak self] _ in
                self?.appCoordinator?.showLoginViewController()
            })
            .disposed(by: disposeBag)
        
        addTweetButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.appCoordinator?.showUploadTweetController()
            })
            .disposed(by: disposeBag)
    }
}
extension MainTabBarController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(addTweetButton)
    }
    func layout() {
        addTweetButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalTo(tabBar.snp.top).offset(-16)
            make.size.equalTo(CGSize(width: 56, height: 56))
        }
    }
}
