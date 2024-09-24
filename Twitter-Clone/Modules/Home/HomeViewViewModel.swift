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
    func likeTweet(tweetId: String)
    func unlikeTweet(tweetId: String)
    func fetchLikedTweets(for userId: String)
}

final class HomeViewViewModel: HomeViewViewModelDelegate {
    let authManager: AuthManagerDelegate
    let databaseManager: DatabaseManagerDelegate
        
    @Published var user: TwitterUser?
    @Published var tweets: [Tweet] = []
    @Published var error: String?
    @Published var likedTweets: Set<String> = []

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
            .handleEvents(receiveOutput: {[weak self] user in
                self?.user = user
                self?.fetchTweets()
            })
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
        databaseManager.retrieveUserAndFollowingTweets(for: userID)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] tweets in
                self?.tweets = tweets
            }
            .store(in: &subscriptions)

    }
    
    func fetchLikedTweets(for userId: String) {
        databaseManager.fetchLikedTweets(userId: userId)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] ids in
                self?.likedTweets = Set(ids)
            }
            .store(in: &subscriptions)
    }
    
    func likeTweet(tweetId: String) {
        guard let userId = Auth.auth().getUserID() else { return }
        databaseManager.likeTweet(userId: userId, tweetId: tweetId)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] liked in
                if liked {
                    self?.likedTweets.insert(tweetId)
                }
            }
            .store(in: &subscriptions)
    }
    
    func unlikeTweet(tweetId: String) {
        guard let userId = Auth.auth().getUserID() else { return }
        databaseManager.unlikeTweet(userId: userId, tweetId: tweetId)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] unliked in
                if unliked {
                    self?.likedTweets.remove(tweetId)
                }
            }
            .store(in: &subscriptions)

    }
    
    func isTweetLiked(tweetId: String) -> Bool {
        return likedTweets.contains(tweetId)
    }
}
