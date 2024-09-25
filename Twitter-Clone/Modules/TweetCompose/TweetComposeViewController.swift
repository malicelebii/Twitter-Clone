//
//  TweetComposeViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 11.09.2024.
//

import UIKit
import Combine

class TweetComposeViewController: UIViewController {
    let tweetComposeViewModel = TweetComposeViewModel()
    var subscriptions: Set<AnyCancellable> = []
    
    let tweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.setTitle("Tweet", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.7), for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    let tweetContentTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8
        textView.textContainerInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        textView.text = "What's happening?"
        textView.textColor = .gray
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        tweetContentTextView.delegate = self
        configureNavigationBar()
        addSubviews()
        configureConstraints()
        tweetButton.addTarget(self, action: #selector(didTapTweet), for: .touchUpInside)
        bindViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          tweetComposeViewModel.getUserData()
      }
    
    func bindViews() {
        tweetComposeViewModel.$isValidToTweet.sink {[weak self] valid in
            self?.tweetButton.isEnabled = valid
        }
        .store(in: &subscriptions)
        
        tweetComposeViewModel.$shouldDismissComposer.sink {[weak self] success in
            if success {
                self?.dismissCompose()
            }
        }
        .store(in: &subscriptions)
        
        
    }
    
    func configureNavigationBar() {
        title = "Tweet Compose"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissCompose))
    }
    
    func addSubviews() {
        view.addSubview(tweetButton)
        view.addSubview(tweetContentTextView)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            tweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            tweetButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            tweetButton.widthAnchor.constraint(equalToConstant: 120),
            tweetButton.heightAnchor.constraint(equalToConstant: 60),
            
            tweetContentTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tweetContentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tweetContentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            tweetContentTextView.bottomAnchor.constraint(equalTo: tweetButton.topAnchor, constant: -10)
        ])
    }
    
    @objc func dismissCompose() {
        dismiss(animated: true)
    }
    
    @objc func didTapTweet() {
        tweetComposeViewModel.sendTweet()
    }
}


extension TweetComposeViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .gray {
            textView.textColor = .label
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What's happening?"
            textView.textColor = .gray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tweetComposeViewModel.tweetContent = textView.text
        tweetComposeViewModel.validateTweetContent()
    }
}
