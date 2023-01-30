//
//  FeedView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit
import SnapKit
import SDWebImage
import RxSwift
import RxCocoa
import RxViewController


class FeedViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties

    var viewModel: FeedViewModel!
    var disposeBag = DisposeBag()
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = .white
        
        titleImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        navigationItem.titleView = titleImageView
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    // MARK: - Methods
    
    func bindViewModel() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        let viewWillAppear = self.rx.viewWillAppear.share()
        
        viewWillAppear.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.navigationBar.isHidden = false
            })
            .disposed(by: disposeBag)
        viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        viewModel.output.userProfileImageView
            .drive(onNext: { [weak self] profileImageView in
                self?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.userTweets
            .bind(to: self.collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { row, tweet, cell in
                let tweetCellModel = TweetCellModel(tweet: tweet)
                cell.bind(cellModel: tweetCellModel)
            }
            .disposed(by: disposeBag)
        viewModel.output.cellProfileImageTapped
            .drive(onNext: { [weak self] user in
                let profileViewModel = ProfileViewModel(user: user)
                var profileViewController = ProfileViewController()
                profileViewController.bind(viewModel: profileViewModel)
                self?.navigationController?.pushViewController(profileViewController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
