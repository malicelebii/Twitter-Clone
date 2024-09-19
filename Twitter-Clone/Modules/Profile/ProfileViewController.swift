//
//  ProfileViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit
import Combine
import Kingfisher
import FirebaseAuth

protocol ProfileHeaderDelegate: AnyObject {
    func didTapFolllowButton()
    func didTapUnfolllowButton()
}

class ProfileViewController: UIViewController {
    let profileViewViewModel: ProfileViewViewModel
    var subscriptions: Set<AnyCancellable> = []
    
    init(profileViewViewModel: ProfileViewViewModel) {
        self.profileViewViewModel = profileViewViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
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
    
    lazy var headerView = ProfileTableViewHeader(frame: CGRect(x: 0, y: 0, width: profileTableView.frame.width, height: 390), isCurrentUser: profileViewViewModel.isUserCurrentUser())
    
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
        headerView.profileView = self
        guard let follower = Auth.auth().getUserID() else { return }
        profileViewViewModel.isUserFollowed(follower: follower, following: profileViewViewModel.user.id)
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
            
            self?.headerView.displayNameLabel.text = user.displayName
            self?.headerView.usernameLabel.text = "@" + user.username
            self?.headerView.followersCountLabel.text = "\(user.followersCount)"
            self?.headerView.followingCountLabel.text = "\(user.followingCount)"
            self?.headerView.userBioLabel.text = user.bio
            self?.headerView.profileAvatarImageView.kf.setImage(with: URL(string: user.avatarPath))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM yyyy"
            let date = dateFormatter.string(from: user.createdOn)
            self?.headerView.joinDateLabel.text = date
        }
        .store(in: &subscriptions)
        
        profileViewViewModel.$tweets.sink {[weak self] _ in
            DispatchQueue.main.async {
                self?.profileTableView.reloadData()
            }
        }
        .store(in: &subscriptions)
        
        profileViewViewModel.$isFollowing.sink {[weak self] bool in
            switch bool {
            case true:
                self?.headerView.configureFollowButtonToUnfollow()
            case false:
                self?.headerView.configureFollowButtonToFollow()
            }
        }
        .store(in: &subscriptions)
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileViewViewModel.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as! TweetTableViewCell
        let tweet = profileViewViewModel.tweets[indexPath.row]
        cell.configureCell(with: tweet)
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

extension ProfileViewController: ProfileHeaderDelegate {
    func didTapFolllowButton() {
        guard let follower = Auth.auth().getUserID() else { return }
        profileViewViewModel.follow(follower: follower, following: profileViewViewModel.user.id)
    }
    
    func didTapUnfolllowButton() {
        guard let follower = Auth.auth().getUserID() else { return }
        profileViewViewModel.unfollow(follower: follower, following: profileViewViewModel.user.id)
    }
}
