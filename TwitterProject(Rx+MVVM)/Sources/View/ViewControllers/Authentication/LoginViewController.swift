//
//  LoginViewController.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit
import RxSwift
import SnapKit
import RxViewController

final class LoginViewController: UIViewController, ViewModelBindable {
    // MARK: - viewModel, disposeBag
    var viewModel: LoginViewModel!
    var disposeBag = DisposeBag()
    // MARK: - UI
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "TwitterLogo")
        return imageView
    }()
    private lazy var emailContainerView: UIView = {
        let view = makeContainerView(image: UIImage(named: "ic_mail_outline_white_2x-1"),textField: emailTextField)
        return view
    }()
    private lazy var passwordContainerView: UIView = {
        let view = makeContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
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
    private lazy var logInButton: UIButton = {
        let button = makeButton(buttonTitle: "Log In")
        return button
    }()
    private lazy var signUpButton: UIButton = {
        let button = attributedButton(firstPart: "Don't have an account", secondPart: " Sign Up")
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, logInButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    // MARK: - vieDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setValue()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        // MARK: - viewModel Input
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.input.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.input.password)
            .disposed(by: disposeBag)
        
        logInButton.rx.tap
            .bind(to: viewModel.input.loginButtonTapped)
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .bind(to: viewModel.input.signUpButtonTapped)
            .disposed(by: disposeBag)
        // MARK: - Output
        _ = viewModel.output
    }
}
// MARK: - LayoutProtocol
extension LoginViewController: LayoutProtocol {
    func setValue() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
    }
    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        view.addSubview(signUpButton)
    }
    func layout() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        emailContainerView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        passwordContainerView.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32))
        }
        signUpButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 16, right: 40))
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
