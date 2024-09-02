//
//  ProfileViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit

class ProfileViewController: UIViewController {

    let profileTableView: UITableView = {
        let profileTableView = UITableView()
        profileTableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        profileTableView.translatesAutoresizingMaskIntoConstraints = false
        return profileTableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Profile"
        addSubviews()
        setupProfileTableView()
        configureConstraints()
        configureProfileHeader()
    }
    
    func addSubviews() {
        view.addSubview(profileTableView)
    }
    
    func setupProfileTableView() {
        profileTableView.dataSource = self
        profileTableView.delegate = self
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configureProfileHeader() {
        let headerView = ProfileTableViewHeader(frame: CGRect(x: 0, y: 0, width: profileTableView.frame.width, height: 390))
        profileTableView.tableHeaderView = headerView
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
}
