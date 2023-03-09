//
//  UploadTweetController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/02.
//


import UIKit

import RxSwift
import RxCocoa
import RxViewController
import SDWebImage



class UploadTweetViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    
    var viewModel: UploadTweetViewModel!
    var disposeBag = DisposeBag()
    
    private var uploadTweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        return button
    }()
    private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.tintColor = .twitterBlue
        return button
    }()
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        imageView.layer.cornerRadius = 48 / 2
        imageView.backgroundColor = .twitterBlue
        return imageView
    }()
    private let captionTextView = CaptionTextView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .leading
        return stackView
    }()
    private let replyLabel: UILabel = {
        let replyLabel = UILabel()
        replyLabel.font = UIFont.systemFont(ofSize: 14)
        replyLabel.textColor = .lightGray
        return replyLabel
    }()
    private lazy var stackViewWithReplyLabel: UIStackView = {
        let stackViewWithReplyLabel = UIStackView(arrangedSubviews: [replyLabel, stackView])
        stackViewWithReplyLabel.axis = .vertical
        stackViewWithReplyLabel.spacing = 12
        stackViewWithReplyLabel.alignment = .leading
        return stackViewWithReplyLabel
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - Methods
    func bindViewModel() {
        // MARK: - Input
        let input = UploadTweetViewModel.Input(viewWillAppear: self.rx.viewWillAppear,
                                               text: captionTextView.rx.text.orEmpty,
                                               uploadTweetButtonTapped: uploadTweetButton.rx.tap,
                                               cancelButtonTapped: cancelButton.rx.tap)
        // MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.userProfileImageUrl.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] url in
                self?.profileImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
    
        output.buttonTitle
            .bind(to: uploadTweetButton.rx.title())
            .disposed(by: disposeBag)
        
        output.placeHolderText
            .bind(to: captionTextView.placeholderLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.captionTextViewPlaceHolderIsHidden
            .bind(to: captionTextView.placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.replyLabelIsHidden
            .bind(to: replyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.replyLabelText
            .bind(to: replyLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

extension UploadTweetViewController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(stackViewWithReplyLabel)
    }
    func layout() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
        
        stackView.snp.makeConstraints { make in
            make.width.equalTo(stackViewWithReplyLabel.snp.width)
        }
        stackViewWithReplyLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalTo(300)
        }
    }
}
