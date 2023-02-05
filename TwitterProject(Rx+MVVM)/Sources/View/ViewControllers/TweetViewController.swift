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
    
    private let headerView = TweetHeaderView()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
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
        headerView.bind(viewModel: viewModel)
    }
}
