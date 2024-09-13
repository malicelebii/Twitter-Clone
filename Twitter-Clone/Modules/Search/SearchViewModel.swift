//
//  SearchViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 13.09.2024.
//

import Foundation
import Combine

protocol SearchViewModelDelegate {
    func search(with query: String, _ completion: @escaping ([TwitterUser]) -> Void)
}

final class SearchViewModel: SearchViewModelDelegate {
    var users: [TwitterUser] = []
    var subscriptions: Set<AnyCancellable> = []
    
    let databaseManager: DatabaseManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func search(with query: String, _ completion: @escaping ([TwitterUser]) -> Void) {
        databaseManager.search(with: query)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { users in
                completion(users)
            }
            .store(in: &subscriptions)

            
    }
}
