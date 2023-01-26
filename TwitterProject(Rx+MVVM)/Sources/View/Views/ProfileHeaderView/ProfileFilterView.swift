//
//  ProfileFiliterView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/17.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileFilterView: UIView {
    
    enum ProfileFilterOptions: Int, CaseIterable {
    case tweets
    case replies
    case likes
    
        var description: String {
            switch self {
            case .tweets: return "Tweets"
            case .replies: return "Tweets & Replies"
            case .likes: return "Likes"
            }
        }
    }
    
    var disposeBag = DisposeBag()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: profileFilterCellIdentifier)
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .left)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind() {
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        collectionView.rx.setDataSource(self)
            .disposed(by: disposeBag)
        collectionView.rx.itemSelected
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { owner, indexPath in
                guard let profileFilterCell = owner.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell else { return }
                let xPosition = profileFilterCell.frame.origin.x
                UIView.animate(withDuration: 0.3) {
                    self.underlineView.frame.origin.x = xPosition
                }
            })
            .disposed(by: disposeBag)
    }
    override func layoutSubviews() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.height.equalTo(2)
            make.width.equalTo(frame.width / 3)
        }
    }
}

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileFilterOptions.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileFilterCellIdentifier, for: indexPath) as! ProfileFilterCell
        cell.titleLabel.text = ProfileFilterOptions(rawValue: indexPath.row)?.description
        return cell
    }
}

extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
