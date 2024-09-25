//
//  HomeViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit
import FirebaseAuth
import Combine

class HomeViewController: UIViewController {
    lazy var homeViewViewModel = HomeViewViewModel()
    private var subscriptions: Set<AnyCancellable> = []

    let composeTweetButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 29/255, green: 161/255, blue: 242/255, alpha: 1)
        button.tintColor = .white
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(plusSign, for: .normal)
        return button
    }()
    
    let timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
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
        addSubViews()
        setupTimeLineTableView()
        configureNavigationBar()
        bindViews()
        configureConstraints()
        composeTweetButton.addTarget(self, action: #selector(didTapComposeTweetButton(_:)), for: .touchUpInside)
    }
    
    func addSubViews() {
        view.addSubview(timelineTableView)
        view.addSubview(composeTweetButton)
        view.addSubview(activityIndicator)
    }
    
    func setupTimeLineTableView() {
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
        activityIndicator.bounds = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        homeViewViewModel.handleAuthentication { vc in
            present(vc, animated: true)
        }
        activityIndicator.startAnimating()
        homeViewViewModel.retrieveUser()
        guard let userId = Auth.auth().getUserID() else { return }
        homeViewViewModel.fetchLikedTweets(for: userId)
    }
    
    func configureNavigationBar() {
        let size: CGFloat = 36
        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.image = UIImage(named: "x")
        let middleView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        middleView.addSubview(logoImageView)
        navigationItem.titleView = middleView
        
        let profileImage = UIImage(systemName: "person")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(didTapProfile))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            composeTweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            composeTweetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -125),
            composeTweetButton.heightAnchor.constraint(equalToConstant: 60),
            composeTweetButton.widthAnchor.constraint(equalToConstant: 60),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        
    }
    
    func bindViews() {
        homeViewViewModel.$user.sink {[weak self] user in
            guard let user = user else { return }
            if !user.isUserOnboarded {
                self?.completeUserOnbarding()
            }
        }
        .store(in: &subscriptions)
        
        homeViewViewModel.$tweets.sink {[weak self] _ in
            DispatchQueue.main.async {
                self?.timelineTableView.reloadData()

            }
        }
        .store(in: &subscriptions)
        
        homeViewViewModel.onTweetsFetched = {[weak self] in
            self?.activityIndicator.stopAnimating()
        }
            
    }
    
    func completeUserOnbarding() {
        let vc = ProfileDataFormViewController()
        present(vc, animated: true)
    }
    
    @objc func didTapProfile() {
        guard let user = homeViewViewModel.user else { return }
        let profileViewModel = ProfileViewViewModel(user: user)
        let vc = ProfileViewController(profileViewViewModel: profileViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapSignOut() {
        let alertController = UIAlertController(title: "Sign Out", message: "Are you sure to sign out ?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: {[weak self] _ in
            self?.homeViewViewModel.signOut()
            self?.homeViewViewModel.handleAuthentication {[weak self] vc in
                self?.present(vc, animated: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    @objc func didTapComposeTweetButton(_ sender: UIButton) {
        let vc = UINavigationController(rootViewController: TweetComposeViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeViewViewModel.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as! TweetTableViewCell
        cell.delegate = self
        let tweet = homeViewViewModel.tweets[indexPath.row]
        cell.setLiked(homeViewViewModel.isTweetLiked(tweetId: tweet.id))
        cell.configureCell(with: tweet)
        return cell
    }
}

extension HomeViewController: TweetTableViewCellDelegate {
    func didTapReply() {
        print("reply")
    }
    
    func didTapRetweet() {
        print("retweet")
    }
    
    func didTapLike(tweetId: String) {
        if homeViewViewModel.isTweetLiked(tweetId: tweetId) {
            homeViewViewModel.unlikeTweet(tweetId: tweetId)
        } else {
            homeViewViewModel.likeTweet(tweetId: tweetId)
        }
    }
    
    func didTapShare() {
        print("share")
    }
    
    
}
