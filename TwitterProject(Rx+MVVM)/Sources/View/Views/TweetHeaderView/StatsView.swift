//
//  StatsView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/02/02.
//

import UIKit
import SnapKit

class StatsView: UIView {
    var viewModel: StatsViewModel!
    
    private let statsView = UIView()
    private let topDivider: UIView = {
        let topDivider = UIView()
        topDivider.backgroundColor = .systemGroupedBackground
        return topDivider
    }()
    private lazy var retweetsLabel: UILabel = {
        let retweetsLabel = UILabel()
        retweetsLabel.font = UIFont.systemFont(ofSize: 14)
        retweetsLabel.text = " 2 Retweets"
        return retweetsLabel
    }()
    private lazy var likesLabel: UILabel = {
        let likesLabel = UILabel()
        likesLabel.font = UIFont.systemFont(ofSize: 14)
        likesLabel.text = " 0 Likes "
        return likesLabel
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    private let bottomDivider: UIView = {
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = .systemGroupedBackground
        return bottomDivider
    }()
    override func layoutSubviews() {
        
        addSubview(topDivider)
        addSubview(stackView)
        addSubview(bottomDivider)
        
        topDivider.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
            make.height.equalTo(1.0)
        }
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(self)
            make.left.equalTo(self.snp.left).offset(16)
        }
        bottomDivider.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1.0)
        }
    }
    func bind(viewModel: TweetViewModel) {
        retweetsLabel.attributedText = viewModel.retweetsAtrributedString
        likesLabel.attributedText = viewModel.likesAtrributedString
    }
}
