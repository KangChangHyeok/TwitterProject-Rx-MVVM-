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
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 350)
        layout.itemSize = CGSize(width: view.frame.width, height: 120)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
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
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    // MARK: - Methods
    
    func bindViewModel() {
        // dataSource
        let dataSource = RxCollectionViewSectionedReloadDataSource<Tweets> { dataSource, collectionView, indexPath, tweet in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
            let tweetCellModel = TweetCellModel(tweet: tweet)
            cell.bind(cellModel: tweetCellModel)
            return cell
        } configureSupplementaryView: { [weak self] dataSource, collectionView, kind , indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeaderView
            header.bindViewModel(viewModel: self?.viewModel)
            self?.viewModel.input.headerBindViewModel.accept(())
            return header
        }
        
        // input
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
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

