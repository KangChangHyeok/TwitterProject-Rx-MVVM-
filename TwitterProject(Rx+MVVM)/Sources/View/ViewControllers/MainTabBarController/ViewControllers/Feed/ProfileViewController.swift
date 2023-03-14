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
    // MARK: - Properties
    
    var viewModel: ProfileViewModel!
    var disposeBag = DisposeBag()
    
    lazy var profileHeaderView = ProfileHeaderView()
    lazy var collectionView: UITableView = {
        
        let tableView = UITableView(frame: .zero)
        tableView.register(TweetCell.self, forCellReuseIdentifier: tweetCellIdentifier)
        tableView.backgroundColor = .systemBackground
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.isHidden = false
        return tableView
    }()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.addSubview(profileHeaderView)
        view.addSubview(collectionView)
        profileHeaderView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(350)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(profileHeaderView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    // MARK: - Methods
    
    func bindViewModel() {
        // input
        profileHeaderView.bind(viewModel: viewModel)
        let viewWillAppear = self.rx.viewWillAppear
        
        viewWillAppear.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.navigationBar.isHidden = true
            })
            .disposed(by: disposeBag)
        viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        //output
//        viewModel.output.userTweets
//            .bind(to: collectionView.rx.items(cellIdentifier: tweetCellIdentifier, cellType: TweetCell.self)) { indexPath, tweet, cell in
//                let tweetCellModel = TweetCellModel(tweet: tweet)
//                cell.cellModel = tweetCellModel
//                cell.bind(tweet: tweet)
//            }
//            .disposed(by: disposeBag)
        
    }
}

