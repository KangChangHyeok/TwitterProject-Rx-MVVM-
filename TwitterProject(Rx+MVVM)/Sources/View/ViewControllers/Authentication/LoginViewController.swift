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

protocol LoginViewControllerDelegate: AnyObject {
    func dismissLoginViewController()
    func showFailToastMeessageView()
    func showRegisterViewController()
}

final class LoginViewController: UIViewController, ViewModelBindable {
    // MARK: - Properties
    weak var loginViewCoordinator: LoginViewControllerDelegate?
    var viewModel: LoginViewModel!
    var disposeBag = DisposeBag()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "TwitterLogo")
        return imageView
    }()
    private lazy var emailContainerView: UIView = {
        let view = Utilites().makeContainerView(image: UIImage(named: "ic_mail_outline_white_2x-1"),textField: emailTextField)
        return view
    }()
    private lazy var passwordContainerView: UIView = {
        let view = Utilites().makeContainerView(image: UIImage(named: "ic_lock_outline_white_2x"), textField: passwordTextField)
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
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        layout()
    }
    // MARK: - bindViewModel
    func bindViewModel() {
        // MARK: - Input
        let input = LoginViewModel.Input(email: emailTextField.rx.text.orEmpty,
                                         password: passwordTextField.rx.text.orEmpty,
                                         loginButtonTapped: logInButton.rx.tap)
        
        // MARK: - Output
        let output = viewModel.transform(input: input)
        
        output.userLoginSucceed
            .drive(onNext: { [weak self] _ in
                self?.loginViewCoordinator?.dismissLoginViewController()
            })
            .disposed(by: disposeBag)
        
        output.userLoginFailed
            .drive(onNext: { [weak self] _ in
                self?.loginViewCoordinator?.showFailToastMeessageView()
            })
            .disposed(by: disposeBag)
        
        signUpButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.loginViewCoordinator?.showRegisterViewController()
            })
            .disposed(by: disposeBag)
    }
}
extension LoginViewController: LayoutProtocol {
    func addSubViews() {
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        view.addSubview(signUpButton)
    }
    func layout() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
        
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
