//
//  TweetViewController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit

import SnapKit
import SDWebImage
import RxSwift
import RxCocoa
import RxViewController

final class TweetViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: TweetViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    private lazy var headerView = TweetHeaderView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(RetweetCell.self, forCellReuseIdentifier: retweetCellIdentifier)
        return tableView
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        headerView.bind(viewModel: viewModel, disposeBag: disposeBag)
        // MARK: - ViewModel Input
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        viewModel.output.repliesForTweet
            .bind(to: tableView.rx.items(cellIdentifier: retweetCellIdentifier, cellType: RetweetCell.self)) { row, tweet, cell in
                cell.bind(tweet: tweet)
                cell.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - LayoutProtocol
extension TweetViewController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(headerView)
        view.addSubview(tableView)
    }
    func layout() {
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(350)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
