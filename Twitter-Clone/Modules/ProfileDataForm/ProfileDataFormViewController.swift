//
//  ProfileDataFormViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 6.09.2024.
//

import UIKit
import PhotosUI
import Combine

class ProfileDataFormViewController: UIViewController {
    let viewModel = ProfileDataFormViewViewModel()
    var subscriptions: Set<AnyCancellable> = []
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    let hintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fill in you data"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    let avatarPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.tintColor = .gray
        imageView.backgroundColor = .lightGray
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 60
        return imageView
    }()
    
    let displayNameTextField: UITextField = { 
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .default
        textField.placeholder = "Display Name"
        textField.textColor = .label
        textField.backgroundColor = .secondarySystemFill
        textField.layer.cornerRadius = 8
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.leftView = view
        textField.leftViewMode = .always
        return textField
    }()
    
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .default
        textField.placeholder = "Username"
        textField.textColor = .label
        textField.backgroundColor = .secondarySystemFill
        textField.layer.cornerRadius = 8
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        textField.leftView = view
        textField.leftViewMode = .always
        return textField
    }()
    
    let bioTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .secondarySystemFill
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.text = "Tell the world about yourself"
        textView.textColor = .gray
        return textView
    }()

    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        isModalInPresentation = true
        addSubviews()
        configureConstraints()
        bioTextView.delegate = self
        displayNameTextField.delegate = self
        usernameTextField.delegate = self
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToDismiss)))
        avatarPlaceholderImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapToUpload)))
        bindViews()
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }
    
    func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(hintLabel)
        scrollView.addSubview(avatarPlaceholderImageView)
        scrollView.addSubview(displayNameTextField)
        scrollView.addSubview(usernameTextField)
        scrollView.addSubview(bioTextView)
        scrollView.addSubview(submitButton)
    }
   
    func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
            hintLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            hintLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            avatarPlaceholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarPlaceholderImageView.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 25),
            avatarPlaceholderImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarPlaceholderImageView.heightAnchor.constraint(equalToConstant: 120),
            
            displayNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            displayNameTextField.topAnchor.constraint(equalTo: avatarPlaceholderImageView.bottomAnchor, constant: 25),
            displayNameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.topAnchor.constraint(equalTo: displayNameTextField.bottomAnchor, constant: 25),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            bioTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bioTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bioTextView.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 25),
            bioTextView.heightAnchor.constraint(equalToConstant: 150),
            
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc func didChangeDisplayName() {
        viewModel.displayName = displayNameTextField.text
        viewModel.validateUserProfileForm()
    }
    
    @objc func didChangeUsername() {
        viewModel.username = usernameTextField.text
        viewModel.validateUserProfileForm()
    }
    
    func bindViews() {
        displayNameTextField.addTarget(self, action: #selector(didChangeDisplayName), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(didChangeUsername), for: .editingChanged)
        viewModel.$isFormValid.sink {[weak self] buttonState in
            self?.submitButton.isEnabled = buttonState
        }
        .store(in: &subscriptions)
    }
    
    @objc func didTapToDismiss() {
        view.endEditing(true)
    }
    
    @objc func didTapToUpload() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func didTapSubmit() {
        viewModel.uploadAvatar()
    }
}

extension ProfileDataFormViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textView.frame.origin.y - 100), animated: true)
        textView.text = ""
        textView.textColor = .label
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell the world about yourself"
            textView.textColor = .gray
        }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        viewModel.bio = textView.text
        viewModel.validateUserProfileForm()
    }
}

extension ProfileDataFormViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: textField.frame.origin.y - 100), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
}

extension ProfileDataFormViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self) {[weak self] object, _ in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self?.avatarPlaceholderImageView.contentMode = .scaleAspectFill
                        self?.avatarPlaceholderImageView.image = image
                        self?.viewModel.imageData = image
                        self?.viewModel.validateUserProfileForm()
                    }
                }
            }
        }
        picker.dismiss(animated: true)
    }
}
