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
    func follow(follower: String, following: String)
    func unfollow(follower: String, following: String)
    func isUserFollowed(follower: String, following: String)
}

final class ProfileViewViewModel: ObservableObject, ProfileViewViewModelDelegate {
    var subscriptions: Set<AnyCancellable> = []
    @Published var user: TwitterUser
    @Published var error: String?
    @Published var tweets: [Tweet] = []
    @Published var isFollowing: Bool = false
    
    let databaseManager: DatabaseManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared, user: TwitterUser) {
        self.databaseManager = databaseManager
        self.user = user
        self.fetchUserTweets()
        guard let follower = Auth.auth().getUserID() else { return  }
        self.isUserFollowed(follower: follower, following: user.id)
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
    
    func follow(follower: String, following: String) {
        databaseManager.follow(follower: follower, following: following)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] state in
                self?.isFollowing = state
            }
            .store(in: &subscriptions)
    }
    
    func unfollow(follower: String, following: String) {
        databaseManager.unFollow(follower: follower, following: following)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] state in
                self?.isFollowing = false
            }
            .store(in: &subscriptions)
    }
    
    func isUserFollowed(follower: String, following: String) {
        databaseManager.isFollowing(follower: follower, following: following)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] following in
                self?.isFollowing = following
                print("following: \(following)")
            }
            .store(in: &subscriptions)
    }
}
