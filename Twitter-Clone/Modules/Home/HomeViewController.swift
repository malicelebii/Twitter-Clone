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
    }
    
    func setupTimeLineTableView() {
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        homeViewViewModel.handleAuthentication { vc in
            present(vc, animated: true)
        }
        homeViewViewModel.retrieveUser()
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
    }
    
    func completeUserOnbarding() {
        let vc = ProfileDataFormViewController()
        present(vc, animated: true)
    }
    
    @objc func didTapProfile() {
        let vc = ProfileViewController()
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
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as! TweetTableViewCell
        cell.delegate = self
        cell.avatarImageView.image = UIImage(systemName: "person")
        cell.displayNameLabel.text = "Mehmet Ali Çelebi"
        cell.usernameLabel.text = "@malicelebi"
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
    
    func didTapLike() {
        print("like")
    }
    
    func didTapShare() {
        print("share")
    }
    
    
}
