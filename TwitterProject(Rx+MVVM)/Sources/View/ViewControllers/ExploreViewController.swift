//
//  ExploreView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxViewController
import SDWebImage

class ExploreViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    var viewModel: ExploreViewModel!
    var disposeBag = DisposeBag()
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UserCell.self, forCellReuseIdentifier: userCellIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        return tableView
    }()
    // MARK: - override
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = .white
        navigationItem.title = "Messages"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    // MARK: - bindViewModel

    func bindViewModel() {
        self.rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        viewModel.output.usersData
            .bind(to: tableView.rx.items(cellIdentifier: userCellIdentifier, cellType: UserCell.self)) { index, user, cell in
                cell.profileImageView.sd_setImage(with: user.profileImageUrl)
                cell.userNameLabel.text = user.fullName
                cell.fullNameLabel.text = user.fullName
            }
            .disposed(by: disposeBag)
        
        
    }
}
