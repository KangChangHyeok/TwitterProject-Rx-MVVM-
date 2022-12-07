//
//  NotificationView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit

class NotificationView: UIViewController {
    // MARK: - Properties
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Methods
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Messages"
    }
}
