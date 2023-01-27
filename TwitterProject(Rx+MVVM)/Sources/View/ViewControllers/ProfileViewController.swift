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


class ProfileViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    
    var viewModel: ProfileViewModel!
    var disposeBag = DisposeBag()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Methods
    
    func configureUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.backgroundColor = .systemBackground
    }
    
    func bindViewModel() {
        // - input
//        collectionView.rx.setDataSource(self)
//            .disposed(by: disposeBag)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        let viewWillAppear = self.rx.viewWillAppear
        viewWillAppear.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.navigationBar.isHidden = true
            })
            .disposed(by: disposeBag)
        viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
//        viewModel.output.userTweets
//            .bind(to: self.collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { _, tweet, cell in
//                let tweetCellModel = TweetCellModel(tweet: tweet)
//                cell.bind(cellModel: tweetCellModel)
//            }
//            .disposed(by: disposeBag)
        viewModel.output.userTweets
            .bind(to: self.collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { _, tweet, cell in
                let tweetCellModel = TweetCellModel(tweet: tweet)
                cell.bind(cellModel: tweetCellModel)
            }
            .disposed(by: disposeBag)
    }
}
extension ProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TweetCell
        return cell
    }
    
    
    
}
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 350)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeaderView
        header.viewModel = self.viewModel
        header.bindViewModel()
        return header
    }
}
