//
//  SearchViewController.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 2.09.2024.
//

import UIKit

class SearchViewController: UIViewController {

    let searchViewModel = SearchViewModel()

    let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: SearchResultsViewController())
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.placeholder = "Search with @username"
        return searchController
    }()
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.text = "Search for users and get connected"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .placeholderText
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(promptLabel)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        configureConstraint()
    }
    
    func configureConstraint() {
        NSLayoutConstraint.activate([
            promptLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsViewController = searchController.searchResultsController as? SearchResultsViewController, let query = searchController.searchBar.text else { return }
        searchViewModel.search(with: query) { users in
            resultsViewController.update(users: users)
        }
       
    }
}
