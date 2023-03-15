//
//  ProfileViewController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/05.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxViewController
import RxDataSources

final class ProfileViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: ProfileViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    lazy var profileHeaderView = ProfileHeaderView()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(RetweetCell.self, forCellReuseIdentifier: retweetCellIdentifier)
        tableView.backgroundColor = .systemBackground
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isHidden = false
        return tableView
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    override func viewDidLayoutSubviews() {
        setValue()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        // MARK: - viewModel Input
        profileHeaderView.bind(viewModel: viewModel)
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        viewModel.output.tweetsForUser
            .bind(to: tableView.rx.items(cellIdentifier: retweetCellIdentifier, cellType: RetweetCell.self)) {
                row, tweet, cell in
                cell.bind(tweet: tweet)
                cell.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - LayoutProtocol
extension ProfileViewController: LayoutProtocol {
    func setValue() {
        navigationController?.navigationBar.isHidden = true
    }
    func addSubViews() {
        view.addSubview(profileHeaderView)
        view.addSubview(tableView)
    }
    func layout() {
        profileHeaderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(350)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(profileHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}
