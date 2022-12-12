//
//  RegisterationView.swift
//  TwitterProject(Rx+MVVM)
//
//  Created by 강창혁 on 2022/12/07.
//


import UIKit

class RegisterationView: UIViewController {
    // MARK: - Properties
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(plusPhtoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let view = Utilites().makeContainerView(image: #imageLiteral(resourceName: "mail"),textField: emailTextField)
        view.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return view
    }()
    private lazy var passwordContainerView: UIView = {
        let view = Utilites().makeContainerView(image: #imageLiteral(resourceName: "ic_lock_outline_white_2x"), textField: passwordTextField)
        view.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return view
    }()
    private lazy var fullNameContainerView: UIView = {
        let view = Utilites().makeContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"),textField: fullNameTextField)
        view.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
        return view
    }()
    private lazy var userNameContainerView: UIView = {
        let view = Utilites().makeContainerView(image: #imageLiteral(resourceName: "ic_person_outline_white_2x"), textField: userNameTextField)
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
    private let fullNameTextField: UITextField = {
        let textField = Utilites().makeTextField(placeHolerString: "Full Name")
        return textField
    }()
    private let userNameTextField: UITextField = {
        let textField = Utilites().makeTextField(placeHolerString: "User Name")
        return textField
    }()
    private let signUpButton: UIButton = {
        let button = Utilites().makeButton(buttonTitle: "Sign Up")
        button.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView,fullNameContainerView,userNameContainerView ,signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let logInButton: UIButton = {
        let button = Utilites().attributedButton(firstPart: "Already have an account?", secondPart: " Log In")
        button.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    // MARK: - Selectros
    @objc func logInButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    @objc func plusPhtoButtonTapped() {
        print("plusPhtoButtonTapped")
    }
    @objc func signUpButtonTapped() {
        
    }
    // MARK: - Methods
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.size.equalTo(CGSize(width: 150, height: 150))
        }
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(plusPhotoButton.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32))
        }
        view.addSubview(logInButton)
        logInButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 16, right: 40))
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
