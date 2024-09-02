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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = "Tweet"
        cell.contentConfiguration = content
        return cell
    }
}
