//
//  ActionSheetLauncher.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/05.
//

import UIKit
import RxSwift
import RxGesture
class ActionSheetLauncher: NSObject {
    var disposeBag = DisposeBag()
    private let user: User
    private let backgroundBackView: UIView = {
        let backgroundBackView = UIView()
        backgroundBackView.alpha = 0
        backgroundBackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return backgroundBackView
    }()
    private let tableView = UITableView()
    private var window: UIWindow?
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
        }
        cancelButton.layer.cornerRadius = 50 / 2
        return view
    }()
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .systemGray6
        return button
    }()
    init(user: User) {
        self.user = user
        super.init()
        configureTableView()
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else { return }
        self.window = window
        window.addSubview(backgroundBackView)
        window.addSubview(tableView)
        
        backgroundBackView.frame = window.frame
        
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: 280)
        backgroundBackView.rx
            .tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .bind { weakself, _ in
                UIView.animate(withDuration: 0.5) {
                    self.backgroundBackView.alpha = 0
                    self.tableView.frame.origin.y += 280
                }
            }
            .disposed(by: disposeBag)
    }
    func show() {

        UIView.animate(withDuration: 0.5) {
            self.backgroundBackView.alpha = 1
            self.tableView.frame.origin.y -= 280
        }
    }
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: "ActionSheetCell")
    }
}

extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActionSheetCell", for: indexPath) as! ActionSheetCell
        return cell
    }
}

extension ActionSheetLauncher: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
}
