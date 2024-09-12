//
//  HomeViewViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 4.09.2024.
//

import UIKit
import FirebaseAuth
import Combine

protocol HomeViewViewModelDelegate {
    func handleAuthentication(completion: (UIViewController) -> Void)
    func signOut()
    func fetchTweets()
}

final class HomeViewViewModel: HomeViewViewModelDelegate {
    let authManager: AuthManagerDelegate
    let databaseManager: DatabaseManagerDelegate
        
    @Published var user: TwitterUser?
    @Published var tweets: [Tweet] = []
    @Published var error: String?

    var subscriptions: Set<AnyCancellable> = []
    
    init(authManager: AuthManagerDelegate = AuthManager.shared, databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.authManager = authManager
        self.databaseManager = databaseManager
    }
    
    func handleAuthentication(completion: (UIViewController) -> Void) {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: OnboardingViewController())
            vc.modalPresentationStyle = .fullScreen
            completion(vc)
        }
    }
    
    func signOut() {
        authManager.signOut()
    }
    
    func retrieveUser() {
        guard let id = Auth.auth().getUserID() else { return }
        
        databaseManager.retrieveUser(with: id)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions)

    }
    
    func fetchTweets() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        databaseManager.retrieveTweets(authorID: userID)
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
