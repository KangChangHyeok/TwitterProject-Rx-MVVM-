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
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    // MARK: - Methods
    
    func configureUI() {
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(ProfileHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.backgroundColor = .systemBackground
        
    }
    
    func bindViewModel() {
        
//        collectionView.rx.setDataSource(self)
//            .disposed(by: disposeBag)
        // - input
        self.rx.viewWillAppear
            .map { _ in
                ()
            }
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        // - output
        
        viewModel.output.userTweets
            .bind(to: collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { row, tweet, cell in
                let tweetCellModel = TweetCellModel(tweet: tweet)
                cell.cellModel = tweetCellModel
                cell.bind(cellModel: tweetCellModel)
            }
            .disposed(by: disposeBag)
        collectionView.rx.setDelegate(self)
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
        header.viewModel = ProfileViewModel.shared
        header.bindViewModel()
        return header
    }
}
