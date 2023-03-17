//
//  ProfileFiliterView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/17.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - ProfileFilterOptions
enum ProfileFilterOptions: Int, CaseIterable {
case tweets
case replies
case likes
    var description: String {
        switch self {
        case .tweets: return "트윗"
        case .replies: return "리트윗"
        case .likes: return "좋아요 누른 트윗"
        }
    }
}
final class ProfileFilterView: UIView {
    
    // MARK: - UI
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: profileFilterCellIdentifier)
        let selectedIndexPath = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .left)
        return collectionView
    }()
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    // MARK: - bind
    func bind(viewModel profileViewModel: ProfileViewModel, disposeBag: DisposeBag) {
        
        collectionView.rx.itemSelected
            .bind(to: profileViewModel.input.itemSelected)
            .disposed(by: disposeBag)
        collectionView.rx.itemSelected
            .withUnretained(self)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { profileFillterView, indexPath in
                guard let profileFilterCell = profileFillterView.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell else { return }
                
                let xPosition = profileFilterCell.frame.origin.x
                UIView.animate(withDuration: 0.3) {
                    self.underlineView.frame.origin.x = xPosition
                }
            })
            .disposed(by: disposeBag)
    }
    // MARK: - layoutSubviews
    override func layoutSubviews() {
        addSubViews()
        layout()
    }
}
// MARK: - UICollectionViewDataSource
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
// MARK: - UICollectionViewDelegateFlowLayout
extension ProfileFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / 3, height: frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
// MARK: - LayoutProtocol
extension ProfileFilterView: LayoutProtocol {
    func addSubViews() {
        addSubview(collectionView)
        addSubview(underlineView)
    }
    func layout() {
        collectionView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        underlineView.snp.makeConstraints { make in
            make.bottom.leading.equalToSuperview()
            make.height.equalTo(2)
            make.width.equalTo(frame.width / 3)
        }
    }
}
