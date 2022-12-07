//
//  FeedView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit

class FeedView: UIViewController {
    // MARK: - Properties
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Methods
    func configureUI() {
        view.backgroundColor = .white
        let titleImageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
    }
}
