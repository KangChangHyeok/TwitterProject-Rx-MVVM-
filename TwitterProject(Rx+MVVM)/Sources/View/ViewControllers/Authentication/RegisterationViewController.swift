//
//  RegisterationView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit
import RxSwift
import RxCocoa

final class RegisterationViewController: UIViewController, ViewModelBindable {
    
    // MARK: - Properties
    
    var viewModel: RegisterationViewModel!
    var disposeBag = DisposeBag()
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = makeContainerView(image: UIImage(named: "ic_mail_outline_white_2x-1"),textField: emailTextField)
        return view
    }()
    private lazy var passwordContainerView: UIView = {
        let view = makeContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
        return view
    }()
    private lazy var fullNameContainerView: UIView = {
        let view = makeContainerView(image: UIImage(named: "ic_person_outline_white_2x"),textField: fullNameTextField)
        return view
    }()
    private lazy var userNameContainerView: UIView = {
        let view = makeContainerView(image: UIImage(named: "ic_person_outline_white_2x"), textField: userNameTextField)
        return view
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = makeTextField(placeHolerString: "Email")
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = makeTextField(placeHolerString: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    private lazy var fullNameTextField: UITextField = {
        let textField = makeTextField(placeHolerString: "Full Name")
        return textField
    }()
    private lazy var userNameTextField: UITextField = {
        let textField = makeTextField(placeHolerString: "User Name")
        return textField
    }()
    private lazy var signUpButton: UIButton = {
        let button = makeButton(buttonTitle: "Sign Up")
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView,fullNameContainerView,userNameContainerView ,signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    private lazy var logInButton: UIButton = {
        let button = attributedButton(firstPart: "Already have an account?", secondPart: " Log In")
        return button
    }()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - Methods
    func bindViewModel() {
        // MARK: - Input
        
        
        let input = RegisterationViewModel.Input(plusPhotoButtonTapped: plusPhotoButton.rx.tap,
                                                 email: emailTextField.rx.text.orEmpty,
                                                 password: passwordTextField.rx.text.orEmpty,
                                                 fullName: fullNameTextField.rx.text.orEmpty,
                                                 userName: userNameTextField.rx.text.orEmpty,
                                                 signUpButtonTapped: signUpButton.rx.tap,
                                                 loginButtonTapped: logInButton.rx.tap)
        // MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.didFinishPicking
            .drive(onNext: { [weak self] image in
                self?.plusPhotoButton.layer.cornerRadius = 150 / 2
                self?.plusPhotoButton.layer.masksToBounds = true
                self?.plusPhotoButton.imageView?.contentMode = .scaleAspectFill
                self?.plusPhotoButton.imageView?.clipsToBounds = true
                self?.plusPhotoButton.layer.borderColor = UIColor.white.cgColor
                self?.plusPhotoButton.layer.borderWidth = 3
                self?.plusPhotoButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            })
            .disposed(by: disposeBag)
    }
}

extension RegisterationViewController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(plusPhotoButton)
        view.addSubview(stackView)
        view.addSubview(logInButton)
    }
    func layout() {
        view.backgroundColor = .twitterBlue
        
        plusPhotoButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        stackView.arrangedSubviews.forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(50)
            }
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(plusPhotoButton.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32))
        }
        logInButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 16, right: 40))
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

private extension RegisterationViewController {
    
    
}
