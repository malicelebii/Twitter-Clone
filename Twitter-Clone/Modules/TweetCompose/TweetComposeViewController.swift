//
//  TweetComposeViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 11.09.2024.
//

import UIKit

class TweetComposeViewController: UIViewController {

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
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        addSubviews()
        configureConstraints()
        tweetButton.addTarget(self, action: #selector(didTapTweet), for: .touchUpInside)
    }
    
        title = "Tweet Compose"
    func addSubviews() {
        view.addSubview(tweetButton)
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            tweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            tweetButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            tweetButton.widthAnchor.constraint(equalToConstant: 120),
            tweetButton.heightAnchor.constraint(equalToConstant: 40),
    
    @objc func didTapTweet() {
        
    }
}


    }
    
    }
}
