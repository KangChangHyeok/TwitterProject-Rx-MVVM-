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

final class TweetViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: TweetViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    private lazy var headerView: TweetHeaderView = {
        let tweetHeaderViewModel = TweetHeaderViewModel(tweet: viewModel.tweet)
        let tweetHeaderView = TweetHeaderView(viewModel: tweetHeaderViewModel)
        tweetHeaderView.bind()
        return tweetHeaderView
    }()
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
        
//        collectionView.rx.setDelegate(self)
//            .disposed(by: disposeBag)
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
//        viewModel.output.repliesForTweet
//            .bind(to: collectionView.rx.items(cellIdentifier: tweetCellIdentifier, cellType: TweetCell.self)) { indexPath, tweet, cell in
//                let tweetCellModel = TweetCellModel(tweet: tweet)
//                cell.cellModel = tweetCellModel
//                cell.bind(tweet: tweet)
//            }
//            .disposed(by: disposeBag)
    }
}

//extension TweetViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let cellHeight = viewModel.getCellHeightForReplies(forwidth: view.frame.width, indexPath: indexPath).height
//        return CGSize(width: view.frame.width, height: cellHeight + 80)
//    }
//}

// MARK: - LayoutProtocol
extension TweetViewController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(headerView)
        view.addSubview(tableView)
    }
    func layout() {
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(viewModel.getCaptionHeight(forwidth: view.frame.width).height + 280)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

