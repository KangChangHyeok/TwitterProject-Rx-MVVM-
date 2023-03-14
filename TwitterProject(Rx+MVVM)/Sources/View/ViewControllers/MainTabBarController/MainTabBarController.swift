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



final class MainTabBarController: UITabBarController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: MainTabViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    override var childForStatusBarStyle: UIViewController? {
        let selectedViewController = selectedViewController as? UINavigationController
        return selectedViewController?.topViewController
    }
    private lazy var addTweetButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.layer.cornerRadius = 28
        button.layer.masksToBounds = true
        return button
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        viewModel.logUserOut()
        // MARK: - viewModel Input
        rx.viewDidAppear
            .bind(to: viewModel.input.viewDidAppear)
            .disposed(by: disposeBag)
        
        addTweetButton.rx.tap
            .bind(to: viewModel.input.addTweetButtonTapped)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        _ = viewModel.output
    }
}
// MARK: - LayoutProtocol
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
