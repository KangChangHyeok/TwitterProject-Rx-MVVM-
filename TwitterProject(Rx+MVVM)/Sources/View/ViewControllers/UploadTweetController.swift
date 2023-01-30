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
import RxViewController

class UploadTweetViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    
    var viewModel: UploadTweetViewModel!
    var disposeBag = DisposeBag()
    
    private var uploadTweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .twitterBlue
        button.setTitle("Tweet", for: .normal)
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
        return stackView
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidLayoutSubviews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0))
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    // MARK: - Methods
    func bindViewModel() {

        self.rx.viewWillAppear
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
        captionTextView.rx.text.orEmpty
            .bind(to: viewModel.input.text)
            .disposed(by: disposeBag)
        uploadTweetButton.rx.tap
            .bind(to: viewModel.input.uploadTweetButtonTapped)
            .disposed(by: disposeBag)
        cancelButton.rx.tap
            .subscribe(onNext: { [ weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        

        viewModel.output.userProfileImageUrl.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] url in
                self?.profileImageView.sd_setImage(with: url)
            })
            .disposed(by: disposeBag)
        viewModel.output.showCaptionTextView
            .drive(onNext: { [weak self] _ in
                self?.captionTextView.placeholderLabel.isHidden = false
            })
            .disposed(by: disposeBag)
        viewModel.output.hideCaptionTextView
            .drive(onNext: { [weak self] _ in
                self?.captionTextView.placeholderLabel.isHidden = true
            })
            .disposed(by: disposeBag)
        viewModel.output.successUploadTweet
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
