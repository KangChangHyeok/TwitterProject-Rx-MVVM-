//
//  UploadTweetController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2023/01/02.
//


import UIKit
import RxSwift
import RxCocoa
import SDWebImage

class UploadTweetViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    
    var viewModel: UploadTweetViewModel!
    var disposeBag = DisposeBag()
    
    private lazy var uploadTweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 64, height: 32)
        button.layer.cornerRadius = 32 / 2
        button.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        return button
    }()
    private let profileImageView: UIImageView = {
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
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Selectors
    @objc func handleCancel() {
        self.dismiss(animated: true)
    }
    @objc func handleUploadTweet() {
        guard let caption = captionTextView.text else { return }
        TweetService.shared.uploadTweet(caption: caption) { error, ref in
            print("DEBUG - upload...")
        }
    }
    // MARK: - Methods
    func bindViewModel() {
        // MARK: - Input

        captionTextView.rx.text.orEmpty
            .bind(to: viewModel.input.text)
            .disposed(by: disposeBag)
        uploadTweetButton.rx.tap
            .bind(to: viewModel.input.uploadTweetButtonTapped)
            .disposed(by: disposeBag)
        
        // MARK: - Output

        viewModel.output.userData
            .drive(onNext: { user in
                guard let imageUrl = user.profileImageUrl else { return }
                self.profileImageView.sd_setImage(with: imageUrl)
            })
            .disposed(by: disposeBag)
        viewModel.output.showCaptionTextView
            .drive(onNext: { _ in
                self.captionTextView.placeholderLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        viewModel.output.hideCaptionTextView
            .drive(onNext: { _ in
                self.captionTextView.placeholderLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        viewModel.output.successUploadTweet
            .drive(onNext: { _ in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    func configureUI() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
        
        let stackView = UIStackView(arrangedSubviews: [profileImageView, captionTextView])
        stackView.axis = .horizontal
        stackView.spacing = 12
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
}
