//
//  ProfileViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit
import Combine
import Kingfisher

class ProfileViewController: UIViewController {
    let profileViewViewModel = ProfileViewViewModel()
    var subscriptions: Set<AnyCancellable> = []
    
    let profileTableView: UITableView = {
        let profileTableView = UITableView()
        profileTableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        profileTableView.translatesAutoresizingMaskIntoConstraints = false
        return profileTableView
    }()
    
    let statusBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.opacity = 0
        return view
    }()
    
    lazy var headerView = ProfileTableViewHeader(frame: CGRect(x: 0, y: 0, width: profileTableView.frame.width, height: 390))
    
    var isStatusBarHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        addSubviews()
        setupProfileTableView()
        configureConstraints()
        configureProfileHeader()
        navigationController?.navigationBar.isHidden = true
        bindViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        profileViewViewModel.retrieveUser()
    }
    
    func addSubviews() {
        view.addSubview(profileTableView)
        view.addSubview(statusBar)
    }
    
    func setupProfileTableView() {
        profileTableView.dataSource = self
        profileTableView.delegate = self
        profileTableView.contentInsetAdjustmentBehavior = .never
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.topAnchor.constraint(equalTo: view.topAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBar.heightAnchor.constraint(equalToConstant: view.bounds.height > 800 ? 40 : 20)
        ])
    }
    
    func configureProfileHeader() {
        profileTableView.tableHeaderView = headerView
    }
    
    func bindViews() {
        profileViewViewModel.$user.sink { [weak self] user in
            guard let user else { return }
            self?.headerView.displayNameLabel.text = user.displayName
            self?.headerView.usernameLabel.text = "@" + user.username
            self?.headerView.followersCountLabel.text = "\(user.followersCount)"
            self?.headerView.followingCountLabel.text = "\(user.followingCount)"
            self?.headerView.userBioLabel.text = user.bio
            self?.headerView.profileAvatarImageView.kf.setImage(with: URL(string: user.avatarPath))
        }
        .store(in: &subscriptions)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as! TweetTableViewCell
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yPosition = scrollView.contentOffset.y
        
        if yPosition > 150 && isStatusBarHidden {
            isStatusBarHidden = false
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) { [weak self] in
                guard let self = self else { return }
                self.statusBar.layer.opacity = 1
            } completion: { _ in }
                
        }else if yPosition < 0 && !isStatusBarHidden {
            isStatusBarHidden = true
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) { [weak self] in
                guard let self = self else { return }
                self.statusBar.layer.opacity = 0
            } completion: { _ in }
        }
    }
}
