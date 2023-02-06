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

class TweetViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    var viewModel: TweetViewModel!
    var disposeBag = DisposeBag()
    
    private lazy var headerView: TweetHeaderView = {
        let tweetHeaderViewModel = TweetHeaderViewModel(tweet: viewModel.tweet)
        let tweetHeaderView = TweetHeaderView(viewModel: tweetHeaderViewModel)
        tweetHeaderView.bind()
        return tweetHeaderView
    }()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.addSubview(headerView)
        view.addSubview(collectionView)
        
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(viewModel.getCaptionHeight(forwidth: view.frame.width).height + 280)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    // MARK: - bindViewModel
    
    func bindViewModel() {
        
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        viewModel.output.repliesForTweet
            .bind(to: collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { indexPath, tweet, cell in
                let tweetCellModel = TweetCellModel(tweet: tweet)
                cell.cellModel = tweetCellModel
                cell.bind()
            }
            .disposed(by: disposeBag)
    }
}

extension TweetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = viewModel.getCellHeightForReplies(forwidth: view.frame.width, indexPath: indexPath).height
        return CGSize(width: view.frame.width, height: cellHeight + 80)
    }
}
