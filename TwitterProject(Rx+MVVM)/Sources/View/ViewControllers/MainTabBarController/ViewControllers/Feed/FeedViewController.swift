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
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        return collectionView
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
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
    }
    // MARK: - bindViewModel
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
        
        viewModel.output.userProfileImageUrl
            .drive(onNext: { [weak self] url in
                guard let self = self else { return }
                self.profileImageView.sd_setImage(with: url)
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.profileImageView)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.userTweets
            .bind(to: self.collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { indexPath, tweet, cell in
                let tweetCellModel = TweetCellModel(tweet: tweet)
                cell.cellModel = tweetCellModel
                cell.bind()
            }
            .disposed(by: disposeBag)
        viewModel.output.cellProfileImageTapped
            .drive(onNext: { [weak self] tweet in
                let profileViewModel = ProfileViewModel(user: tweet.user)
                let profileViewController = ProfileViewController()
                profileViewController.bind(viewModel: profileViewModel)
                self?.navigationController?.pushViewController(profileViewController, animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.output.showRetweetViewController
            .drive(onNext: { tweet in
                let uploadTweetViewModel = UploadTweetViewModel(type: .reply(tweet))
                let uploadTweetViewController = UploadTweetViewController()
                uploadTweetViewController.bind(viewModel: uploadTweetViewModel)
                let navigationController = UINavigationController(rootViewController: uploadTweetViewController)
                navigationController.modalPresentationStyle = .fullScreen
                self.present(navigationController, animated: true)
            })
            .disposed(by: disposeBag)
        collectionView.rx.itemSelected
            .withUnretained(self)
            .bind { weakself, indexPath in
                guard let selectedCell = weakself.collectionView.cellForItem(at: indexPath) as? TweetCell else { return }
                let selectedCellTweetData = selectedCell.cellModel.tweet
                let tweetViewModel = TweetViewModel(tweet: selectedCellTweetData)
                let tweetViewController = TweetViewController()
                tweetViewController.bind(viewModel: tweetViewModel)
                weakself.navigationController?.pushViewController(tweetViewController, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = viewModel.getCellHeight(forwidth: view.frame.width, indexPath: indexPath).height

        return CGSize(width: view.frame.width, height: cellHeight + 80)
    }
}
