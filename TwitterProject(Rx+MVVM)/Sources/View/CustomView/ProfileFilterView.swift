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
    
    
    var disposeBag = DisposeBag()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        bindViewModel()
        collectionView.register(ProfileFilterCell.self, forCellWithReuseIdentifier: profileFilterCellIdentifier)
        print(frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel() {
        collectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { indexPath in
                guard let profileFilterCell = self.collectionView.cellForItem(at: indexPath) as? ProfileFilterCell else { return }
                let xPosition = profileFilterCell.frame.origin.x
                UIView.animate(withDuration: 0.3) {
                    self.underlineView.frame.origin.x = xPosition
                }
            })
            .disposed(by: disposeBag)
    }
    //frame이 생긴이후에 실행 함수
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
