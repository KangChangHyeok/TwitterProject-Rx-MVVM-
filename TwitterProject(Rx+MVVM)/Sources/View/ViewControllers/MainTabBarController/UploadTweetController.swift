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
    // MARK: - viewModel, DisposeBag
    var viewModel: UploadTweetViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
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
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.titleLabel?.tintColor = .twitterBlue
        return button
    }()
    private var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
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
        rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        
        captionTextView.rx.text.orEmpty
            .bind(to: viewModel.input.text)
            .disposed(by: disposeBag)
        
        uploadTweetButton.rx.tap
            .bind(to: viewModel.input.uploadTweetButtonTapped)
            .disposed(by: disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.input.cancelButtonTapped)
            .disposed(by: disposeBag)
        // MARK: - viewModel Output
        viewModel.output.userProfileImageUrl
            .withUnretained(self)
            .subscribe(onNext: { uploadTweetViewController, url in
                uploadTweetViewController.profileImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.buttonTitle
            .bind(to: uploadTweetButton.rx.title())
            .disposed(by: disposeBag)
        
        viewModel.output.placeHolderText
            .bind(to: captionTextView.placeholderLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.captionTextViewPlaceHolderIsHidden
            .bind(to: captionTextView.placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.replyLabelIsHidden
            .bind(to: replyLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.output.replyLabelText
            .bind(to: replyLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.output.captionText
            .bind(to: captionTextView.rx.text)
            .disposed(by: disposeBag)
    }
}
// MARK: - LayoutProtocol
extension UploadTweetViewController: LayoutProtocol {
    func setValue() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
    }
    func addSubViews() {
        view.addSubview(stackViewWithReplyLabel)
    }
    func layout() {
        stackView.snp.makeConstraints { make in
            make.width.equalTo(stackViewWithReplyLabel.snp.width)
        }
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        stackViewWithReplyLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
            make.height.equalTo(300)
        }
    }
}
