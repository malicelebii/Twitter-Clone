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
    func fetchUserTweets()
}

final class ProfileViewViewModel: ObservableObject, ProfileViewViewModelDelegate {
    var subscriptions: Set<AnyCancellable> = []
    @Published var user: TwitterUser
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    
    let databaseManager: DatabaseManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared, user: TwitterUser) {
        self.databaseManager = databaseManager
        self.user = user
        self.fetchUserTweets()
    }
    
    func fetchUserTweets() {
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
