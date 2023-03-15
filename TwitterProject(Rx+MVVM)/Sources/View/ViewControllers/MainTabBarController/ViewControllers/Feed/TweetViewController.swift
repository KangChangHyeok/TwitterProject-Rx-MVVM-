//
//  TweetViewController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit

import SnapKit
import SDWebImage
import RxSwift
import RxCocoa
import RxViewController
import RxDataSources



final class TweetViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: TweetViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    private lazy var headerView = TweetHeaderView()
    private lazy var retweetCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero)
        return collectionView
    }()
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<Tweets> { dataSource, collectionView, indexPath, tweet in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: retweetCellIdentifier, for: indexPath) as! RetweetCell
            cell.bind(tweet: tweet)
        } configureSupplementaryView: { dataSource, collectionView, string, indexPath in
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: string, withReuseIdentifier: <#T##String#>, for: <#T##IndexPath#>)
        }

        
        // MARK: - ViewModel Input
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        headerView.retweetButton.rx.tap
            .bind(to: viewModel.input.retweetButtonTapped)
            .disposed(by: disposeBag)
        headerView.likeButton.rx.tap
            .bind(to: viewModel.input.likeButtonTapped)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        viewModel.output.profileImageUrl
            .withUnretained(self)
            .bind { tweetViewController, url in
                tweetViewController.headerView.profileImageView.sd_setImage(with: url)
            }
            .disposed(by: disposeBag)
        viewModel.output.userFullName
            .bind(to: headerView.fullnameLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.userName
            .bind(to: headerView.usernameLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.caption
            .bind(to: headerView.captionLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.date
            .bind(to: headerView.dateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.output.retweetCount
            .bind(to: headerView.statsView.retweetsLabel.rx.attributedText)
            .disposed(by: disposeBag)
        viewModel.output.likesCount
            .bind(to: headerView.statsView.likesLabel.rx.attributedText)
            .disposed(by: disposeBag)
        viewModel.output.likeButtonImage
            .bind(to: headerView.likeButton.rx.image())
            .disposed(by: disposeBag)
        
    }
}

// MARK: - LayoutProtocol
extension TweetViewController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(headerView)
        view.addSubview(retweetCollectionView)
    }
    func layout() {
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(350)
        }
        retweetCollectionView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
