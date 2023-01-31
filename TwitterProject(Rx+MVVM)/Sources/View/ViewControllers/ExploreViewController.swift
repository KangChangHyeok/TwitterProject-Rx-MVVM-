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
    
    private let serachController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "유저를 검색하세요"
        return searchController
    }()
    
    // MARK: - override
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = .white
        navigationItem.title = "Explore"
        navigationItem.searchController = serachController
        definesPresentationContext = false
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
        self.rx.viewWillAppear
            .bind(onNext: { [weak self] _ in
                self?.navigationController?.navigationBar.isHidden = false
            })
            .disposed(by: disposeBag)
        serachController.searchBar.rx.text.orEmpty
            .bind(to: viewModel.input.searchBarText)
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                let cell = self?.tableView.cellForRow(at: indexPath) as! UserCell
                let user = cell.cellModel.user
                let profileViewModel = ProfileViewModel(user: user)
                var profileViewController = ProfileViewController()
                profileViewController.bind(viewModel: profileViewModel)
                self?.navigationController?.pushViewController(profileViewController, animated: true)
            }
            .disposed(by: disposeBag)
        viewModel.output.usersData
            .bind(to: tableView.rx.items(cellIdentifier: userCellIdentifier, cellType: UserCell.self)) { index, user, cell in
                let userCellModel = UserCellModel(user: user)
                cell.cellModel = userCellModel
                cell.bind()
            }
            .disposed(by: disposeBag)
    }
}
