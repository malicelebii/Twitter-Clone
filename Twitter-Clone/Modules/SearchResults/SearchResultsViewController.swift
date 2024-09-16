//
//  SearchResultsViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 13.09.2024.
//

import UIKit

class SearchResultsViewController: UIViewController {
    let searchResultsViewModel = SearchResultsViewModel()
    
    let searchResultsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchResultsTableView)
        configureConstraints()
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
    }

    func configureConstraints() {
        NSLayoutConstraint.activate([
            searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchResultsTableView.topAnchor.constraint(equalTo: view.topAnchor),
            searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func update(users: [TwitterUser]) {
        searchResultsViewModel.users = users
        DispatchQueue.main.async {[weak self] in
            self?.searchResultsTableView.reloadData()
        }
    }
}

extension SearchResultsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResultsViewModel.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = searchResultsViewModel.users[indexPath.row].displayName
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = searchResultsViewModel.users[indexPath.row]
        let profileViewModel = ProfileViewViewModel(user: user)
        let vc = ProfileViewController(profileViewViewModel: profileViewModel)
        present(vc, animated: true)
    }
}
