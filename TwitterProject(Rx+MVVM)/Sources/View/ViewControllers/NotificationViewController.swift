//
//  NotificationView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit
import RxSwift
import RxCocoa
import SnapKit
import RxViewController

class NotificationViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    var viewModel: NotificationViewModel!
    var disposeBag = DisposeBag()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NotificationCell.self, forCellReuseIdentifier: notificationCellIdentifier)
        return tableView
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    func bindViewModel() {
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        rx.viewWillAppear
            .withUnretained(self)
            .bind { weakself, _ in
                weakself.navigationController?.navigationBar.isHidden = false
                weakself.navigationController?.navigationBar.barStyle = .default
            }
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .debug("----")
            .withUnretained(self)
            .bind { weakself, indexPath in
                guard let selectedCell = weakself.tableView.cellForRow(at: indexPath) as? NotificationCell else { return }
                guard let selectedCellTweetData = selectedCell.cellModel.notification.tweet else { return }
                print(selectedCellTweetData)
                let tweetViewModel = TweetViewModel(tweet: selectedCellTweetData)
                var tweetViewController = TweetViewController()
                tweetViewController.bind(viewModel: tweetViewModel)
                weakself.navigationController?.pushViewController(tweetViewController, animated: true)
            }
            .disposed(by: disposeBag)
        viewModel.output.notifications
            .bind(to: tableView.rx.items(cellIdentifier: notificationCellIdentifier, cellType: NotificationCell.self)) { row, notification, cell in
                let cellModel = NotificationCellModel(notification: notification)
                cell.cellModel = cellModel
                cell.bind()
            }
            .disposed(by: disposeBag)
    }
}
