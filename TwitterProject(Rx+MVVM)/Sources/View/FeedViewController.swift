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

class FeedViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties

    var viewModel: FeedViewModel!
    var disposeBag = DisposeBag()
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
    }
}