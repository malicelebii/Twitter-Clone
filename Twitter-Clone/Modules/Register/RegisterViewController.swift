//
//  RegisterViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 3.09.2024.
//

import UIKit
import Combine

class RegisterViewController: UIViewController {

    let registerViewModel = RegisterViewModel()
    var subscriptions: Set<AnyCancellable> = []
    
    let registerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Create your account"
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
    
    let registerButton: UIButton = {
        let register = UIButton(type: .system)
        register.translatesAutoresizingMaskIntoConstraints = false
        register.setTitle("Create account", for: .normal)
        register.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        register.tintColor = .white
        register.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        register.layer.cornerRadius = 30
        register.layer.masksToBounds = true
        register.isEnabled = false
        return register
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        configureConstraints()
        bindViews()
    }
    
    func addSubviews() {
        view.addSubview(registerTitleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(registerButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            registerTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.topAnchor.constraint(equalTo: registerTitleLabel.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            emailTextField.heightAnchor.constraint(equalToConstant: 60),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            registerButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            registerButton.heightAnchor.constraint(equalToConstant: 60),
            registerButton.widthAnchor.constraint(equalToConstant: 180)
        ])
    }
    
    @objc func didChangeEmail() {
        registerViewModel.email = emailTextField.text
        registerViewModel.validateRegistrationForm()
    }
    
    @objc func didChangePassword() {
        registerViewModel.password = passwordTextField.text
        registerViewModel.validateRegistrationForm()
    }
    
    func bindViews() {
        emailTextField.addTarget(self, action: #selector(didChangeEmail), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didChangePassword), for: .editingChanged)
        registerViewModel.$isRegistrationFormValid.sink { [weak self] validationState in
            guard let self = self else { return }
            self.registerButton.isEnabled = validationState
        }
        .store(in: &subscriptions)
    }
}
