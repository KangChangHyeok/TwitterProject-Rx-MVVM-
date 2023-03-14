//
//  TweetViewController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit

import RxSwift
import RxCocoa
import RxViewController
import SnapKit
import SDWebImage

final class TweetViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: TweetViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    private lazy var headerView = TweetHeaderView()
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(TweetCell.self, forCellReuseIdentifier: tweetCellIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
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
        
        // MARK: - ViewModel Input
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        headerView.retweetButton.rx.tap
            .bind(to: viewModel.input.retweetButtonTapped)
            .disposed(by: disposeBag)
        headerView.likeButton.rx.tap
            .bind(to: viewModel.input.likeButtonTapped)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        viewModel.output.profileImageUrl
            .withUnretained(self)
            .bind { tweetViewController, url in
                tweetViewController.headerView.profileImageView.sd_setImage(with: url)
            }
            .disposed(by: disposeBag)
        viewModel.output.userFullName
            .bind(to: headerView.fullnameLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.userName
            .bind(to: headerView.usernameLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.caption
            .bind(to: headerView.captionLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.date
            .bind(to: headerView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.retweetCount
            .bind(to: headerView.statsView.retweetsLabel.rx.attributedText)
            .disposed(by: disposeBag)
        viewModel.output.likesCount
            .bind(to: headerView.statsView.likesLabel.rx.attributedText)
            .disposed(by: disposeBag)
        viewModel.output.likeButtonImage
            .bind(to: headerView.likeButton.rx.image())
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
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

