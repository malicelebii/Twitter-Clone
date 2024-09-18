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
    func isUserCurrentUser() -> Bool
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
    
    func retrieveUser(with id: String) {
        databaseManager.retrieveUser(with: id)
            .handleEvents(receiveOutput: {[weak self] user in
                self?.user = user
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
                self?.retrieveUser(with: following)
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
                self?.retrieveUser(with: following)
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
    
    func isUserCurrentUser() -> Bool {
        return user.id == Auth.auth().getUserID()
    }
}
