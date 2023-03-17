//
//  FeedView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit

import RxSwift
import RxCocoa
import RxViewController
import SnapKit
import SDWebImage

final class FeedViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: FeedViewModel!
    var disposeBag = DisposeBag()
    
    lazy var feedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TweetCell.self, forCellReuseIdentifier: tweetCellIdentifier)
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    private let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.layer.cornerRadius = 32 / 2
        profileImageView.layer.masksToBounds = true
        return profileImageView
    }()
    let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue()
        addSubViews()
        layout()
    }
    // MARK: - viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        navigationController?.navigationBar.isHidden = false
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        // MARK: - ViewModel Input
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        // MARK: - ViewModel Output
        viewModel.output.userProfileImageUrl
            .withUnretained(self)
            .subscribe(onNext: { feedViewController, url in
                feedViewController.profileImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
        viewModel.output.tweetCellModels
            .bind(to: feedTableView.rx.items(cellIdentifier: tweetCellIdentifier, cellType: TweetCell.self)) { row, tweetCellModel, cell in
                cell.bind(cellModel: tweetCellModel)
                cell.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
        
    }
}
// MARK: - LayoutProtocol
extension FeedViewController: LayoutProtocol {
    func setValue() {
        view.backgroundColor = .white
        navigationItem.titleView = titleImageView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
    }
    func addSubViews() {
        view.addSubview(feedTableView)
    }
    func layout() {
        titleImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        feedTableView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
    }
}
