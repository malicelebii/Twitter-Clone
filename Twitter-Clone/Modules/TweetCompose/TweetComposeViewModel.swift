//
//  TweetComposeViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 11.09.2024.
//

import Foundation
import FirebaseAuth
import Combine

protocol TweetComposeViewModelDelegate {
    func getUserData()
}

final class TweetComposeViewModel: ObservableObject, TweetComposeViewModelDelegate {
    let databaseManager: DatabaseManagerDelegate
    var subscriptions: Set<AnyCancellable> = []
    @Published var error: String?
    @Published var user: TwitterUser?
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func getUserData() {
         guard let userID = Auth.auth().currentUser?.uid else { return }
        databaseManager.retrieveUser(with: userID)
             .sink { [weak self] completion in
                 if case .failure(let error) = completion {
                     self?.error = error.localizedDescription
                 }
             } receiveValue: { [weak self] twitterUser in
                 self?.user = twitterUser
             }
             .store(in: &subscriptions)
     }
}
