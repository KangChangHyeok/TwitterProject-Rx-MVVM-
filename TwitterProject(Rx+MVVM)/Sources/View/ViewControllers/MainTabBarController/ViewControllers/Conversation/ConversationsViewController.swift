//
//  ConversationsView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit

class ConversationsViewController: UIViewController {
    // MARK: - Properties
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
    }
}
