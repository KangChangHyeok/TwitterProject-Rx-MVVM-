//
//  File.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//

import UIKit
import RxSwift
import SnapKit
import RxViewController

class LoginViewController: UIViewController, ViewModelBindable {
    
    var viewModel: LoginViewModel!
    var disposeBag = DisposeBag()
    // MARK: - Properties
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "TwitterLogo")
        return imageView
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilites().makeContainerView(image: UIImage(named: "ic_mail_outline_white_2x-1"),textField: emailTextField)
        view.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return view
    }()
    private lazy var passwordContainerView: UIView = {
        let view = Utilites().makeContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = Utilites().makeTextField(placeHolerString: "Email")
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = Utilites().makeTextField(placeHolerString: "Password")
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let logInButton: UIButton = {
        let button = Utilites().makeButton(buttonTitle: "Log In")
        return button
    }()
    
    private let signUpButton: UIButton = {
        let button = Utilites().attributedButton(firstPart: "Don't have an account", secondPart: " Sign Up")
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, logInButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barStyle = .black
    }
    // MARK: - Methods
    func bindViewModel() {
        //input
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
            .subscribe(onNext: { [weak self] _ in
                var registerViewController = RegisterationViewController()
                let registerViewModel = RegisterationViewModel()
                registerViewController.bind(viewModel: registerViewModel)
                self?.navigationController?.pushViewController(registerViewController, animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.output.successLogin
            .drive(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        viewModel.output.failureLogin
            .drive(onNext: { _ in
                print("DEBUG - 로그인 실패")
            })
            .disposed(by: disposeBag)
    }
    func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32))
        }
        view.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 16, right: 40))
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
