//
//  ExploreView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit

import SnapKit
import SDWebImage

import RxSwift
import RxCocoa
import RxViewController


final class ExploreViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
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
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        // MARK: - viewModel Input
        self.rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        serachController.searchBar.rx.text.orEmpty
            .bind(to: viewModel.input.searchBarText)
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(User.self)
            .bind(to: viewModel.input.userCellTapped)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        viewModel.output.usersData
            .bind(to: tableView.rx.items(cellIdentifier: userCellIdentifier, cellType: UserCell.self)) { index, user, cell in
                cell.bind(user: user)
            }
            .disposed(by: disposeBag)
    }
}
// MARK: - LayoutProtocol
extension ExploreViewController: LayoutProtocol {
    func setValue() {
        self.navigationController?.navigationBar.isHidden = false
        view.backgroundColor = .white
        navigationItem.title = "Explore"
        navigationItem.searchController = serachController
        definesPresentationContext = false
    }
    func addSubViews() {
        view.addSubview(tableView)
    }
    func layout() {
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}
