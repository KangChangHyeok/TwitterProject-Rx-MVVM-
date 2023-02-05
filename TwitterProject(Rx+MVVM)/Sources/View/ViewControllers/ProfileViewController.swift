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



class ProfileViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    
    var viewModel: ProfileViewModel!
    var disposeBag = DisposeBag()
    
    lazy var profileHeaderView = ProfileHeaderView()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 120)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.isHidden = false
        return collectionView
    }()
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
        viewModel.output.userTweets
            .bind(to: collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { indexPath, tweet, cell in
                let tweetCellModel = TweetCellModel(tweet: tweet)
                cell.cellModel = tweetCellModel
                cell.bind()
            }
            .disposed(by: disposeBag)
    }
}

