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

private let reuseIdentifier = "tweetCell"

class FeedViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties

    var viewModel: FeedViewModel!
    var disposeBag = DisposeBag()
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Methods
    func configureUI() {
        view.backgroundColor = .white
        let titleImageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        titleImageView.contentMode = .scaleAspectFit
        titleImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        navigationItem.titleView = titleImageView
        collectionView.backgroundColor = .white
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    func bindViewModel() {
        viewModel.output.user
            .drive(onNext: { [weak self] user in
                let profileImageView = UIImageView()
                profileImageView.backgroundColor = .twitterBlue
                profileImageView.snp.makeConstraints { make in
                    make.size.equalTo(CGSize(width: 32, height: 32))
                }
                profileImageView.layer.cornerRadius = 32 / 2
                profileImageView.layer.masksToBounds = true
                
                guard let profileImageUrl = user.profileImageUrl else { return }
                profileImageView.sd_setImage(with: profileImageUrl)
                
                self?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
            })
            .disposed(by: disposeBag)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        viewModel.output.userTweets
            .debug()
            .bind(to: self.collectionView.rx.items(cellIdentifier: reuseIdentifier, cellType: TweetCell.self)) { row, tweets, cell in
            }
            .disposed(by: disposeBag)
    }
}
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
