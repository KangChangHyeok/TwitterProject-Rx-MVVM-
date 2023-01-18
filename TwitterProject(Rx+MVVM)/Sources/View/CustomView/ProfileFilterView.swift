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
    
    var viewModel: ProfileFilterViewModel!
    var disposeBag = DisposeBag()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override init(frame: CGRect) {
        let profileFilterViewModel = ProfileFilterViewModel()
        viewModel = profileFilterViewModel
        super.init(frame: frame)
        bindViewModel()
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: profileFilterCellIdentifier)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel() {
        let profileFilterCell = collectionView.rx.itemSelected
            .map { indexPath in
                if let profileFilterCell = self.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell {
                    return profileFilterCell
                }
                return ProfileFilterCell()
            }
        profileFilterCell
            .bind(to: viewModel.input.profileFilterCell)
            .disposed(by: disposeBag)
    }
}

extension ProfileFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileFilterCellIdentifier, for: indexPath) as! ProfileFilterCell
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
