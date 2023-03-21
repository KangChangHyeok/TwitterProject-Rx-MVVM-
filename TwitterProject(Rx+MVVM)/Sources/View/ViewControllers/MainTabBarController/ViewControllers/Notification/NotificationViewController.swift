//
//  NotificationView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit

import SnapKit

import RxSwift
import RxCocoa
import RxViewController

final class NotificationViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: NotificationViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(NotificationCell.self, forCellReuseIdentifier: notificationCellIdentifier)
        return tableView
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        setValue()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
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
// MARK: - LayoutProtocol
extension NotificationViewController: LayoutProtocol {
    func setValue() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    func addSubViews() {
        view.addSubview(tableView)
    }
    func layout() {
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}
