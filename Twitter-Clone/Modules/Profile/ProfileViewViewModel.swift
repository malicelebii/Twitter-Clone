//
//  ProfileViewViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 10.09.2024.
//

import Foundation
import Combine
import FirebaseAuth

protocol ProfileViewViewModelDelegate {
    func retrieveUser()
    func fetchUserTweets()
}

final class ProfileViewViewModel: ObservableObject, ProfileViewViewModelDelegate {
    var subscriptions: Set<AnyCancellable> = []
    @Published var user: TwitterUser?
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    
    let databaseManager: DatabaseManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    
    func retrieveUser() {
        guard let id = Auth.auth().getUserID() else { return }
        
        databaseManager.retrieveUser(with: id)
            .handleEvents(receiveOutput: {[weak self] user in
                self?.user = user
                self?.fetchUserTweets()
            })
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] user in
                print(user)
                self?.user = user
            }
            .store(in: &subscriptions)

    }
    
    func fetchUserTweets() {
        guard let user else { return }
        databaseManager.retrieveTweets(authorID: user.id)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] tweets in
                self?.tweets = tweets
            }
            .store(in: &subscriptions)
    }
}
