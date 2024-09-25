//
//  LoginViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 4.09.2024.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    let authenticationViewModel = AuthenticationViewModel()
    var subscriptions: Set<AnyCancellable> = []

    let loginTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Log in"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email..."
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password..."
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = {
        let register = UIButton(type: .system)
        register.translatesAutoresizingMaskIntoConstraints = false
        register.setTitle("Login", for: .normal)
        register.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        register.tintColor = .white
        register.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        register.layer.cornerRadius = 30
        register.layer.masksToBounds = true
        register.isEnabled = false
        return register
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .systemGray
        activityIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        configureConstraints()
        bindViews()
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }
    
    func addSubviews() {
        view.addSubview(loginTitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(activityIndicator)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            loginTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.topAnchor.constraint(equalTo: loginTitleLabel.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            emailTextField.heightAnchor.constraint(equalToConstant: 60),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 60),
            loginButton.widthAnchor.constraint(equalToConstant: 180),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    @objc func didChangeEmail() {
        authenticationViewModel.email = emailTextField.text
        authenticationViewModel.validateRegistrationForm()
    }
    
    @objc func didChangePassword() {
        authenticationViewModel.password = passwordTextField.text
        authenticationViewModel.validateRegistrationForm()
    }
    
    @objc func didTapRegister() {
        authenticationViewModel.createUser()
    }
    
    func bindViews() {
        emailTextField.addTarget(self, action: #selector(didChangeEmail), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didChangePassword), for: .editingChanged)
        authenticationViewModel.$isAuthenticationFormValid.sink { [weak self] validationState in
            guard let self = self else { return }
            self.loginButton.isEnabled = validationState
        }
        .store(in: &subscriptions)
        
        authenticationViewModel.$user.sink {[weak self] user in
            guard user != nil else { return }
            guard let vc = self?.navigationController?.viewControllers.first as? OnboardingViewController else { return }
            vc.dismiss(animated: true)
        } .store(in: &subscriptions)
        
        authenticationViewModel.$error.sink { [weak self] errorString in
            guard let error = errorString else { return }
            let ac = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
        .store(in: &subscriptions)
        
        authenticationViewModel.didEndProcess = { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    @objc func didTapLogin() {
        activityIndicator.startAnimating()
        authenticationViewModel.login()
    }
}
