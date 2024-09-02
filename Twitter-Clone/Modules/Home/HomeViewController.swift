//
//  HomeViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit

class HomeViewController: UIViewController {

    let timelineTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupTimeLineTableView()
    }
    
    func addSubViews() {
        view.addSubview(timelineTableView)
    }
    
    func setupTimeLineTableView() {
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as! TweetTableViewCell
        cell.avatarImageView.image = UIImage(systemName: "person")
        cell.displayNameLabel.text = "Mehmet Ali Çelebi"
        cell.usernameLabel.text = "@malicelebi"
        return cell
    }
}
