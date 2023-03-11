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

class FeedViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    
    var viewModel: FeedViewModel!
    var disposeBag = DisposeBag()
    
    lazy var feedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(TweetCell.self, forCellReuseIdentifier: tweetCellIdentifier)
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
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
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        // MARK: - ViewModel Input
        self.rx.viewWillAppear
            .bind(to: self.viewModel.input.viewWillAppear)
            .disposed(by: self.disposeBag)
        
        // MARK: - ViewModel Output
        self.viewModel.output.userProfileImageUrl
            .drive(onNext: { [weak self] url in
                self?.profileImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
        self.viewModel.output.usersTweets
            .bind(to: feedTableView.rx.items(cellIdentifier: tweetCellIdentifier, cellType: TweetCell.self)) { [weak self] row, tweet, cell in
                guard let weakself = self else { return }
                cell.bind(tweet: tweet, viewModel: weakself.viewModel)
                cell.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
            
//        viewModel.output.cellProfileImageTapped
//            .drive(onNext: { [weak self] tweet in
//                let profileViewModel = ProfileViewModel(user: tweet.user)
//                let profileViewController = ProfileViewController()
//                profileViewController.bind(viewModel: profileViewModel)
//                self?.navigationController?.pushViewController(profileViewController, animated: true)
//            })
//            .disposed(by: disposeBag)
//        viewModel.output.showRetweetViewController
//            .drive(onNext: { tweet in
//                let uploadTweetViewModel = UploadTweetViewModel(type: .reply(tweet))
//                let uploadTweetViewController = UploadTweetViewController()
//                uploadTweetViewController.bind(viewModel: uploadTweetViewModel)
//                let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
//                navigationController.modalPresentationStyle = .fullScreen
//                self.present(navigationController, animated: true)
//            })
//            .disposed(by: disposeBag)
//        collectionView.rx.itemSelected
//            .withUnretained(self)
//            .bind { weakself, indexPath in
//                guard let selectedCell = weakself.collectionView.cellForItem(at: indexPath) as? TweetCell else { return }
//                let selectedCellTweetData = selectedCell.cellModel.tweet
//                let tweetViewModel = TweetViewModel(tweet: selectedCellTweetData)
//                let tweetViewController = TweetViewController()
//                tweetViewController.bind(viewModel: tweetViewModel)
//                weakself.navigationController?.pushViewController(tweetViewController, animated: true)
//            }
//            .disposed(by: disposeBag)
    }
}

extension FeedViewController: LayoutProtocol {
    func setValue() {
        
    }
    func addSubViews() {
        view.addSubview(feedTableView)
    }
    
    func layout() {
        view.backgroundColor = .white
        navigationItem.titleView = titleImageView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        navigationController?.navigationBar.isHidden = true
        
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
