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
    func validateTweetContent()
    func sendTweet()
}

final class TweetComposeViewModel: ObservableObject, TweetComposeViewModelDelegate {
    let databaseManager: DatabaseManagerDelegate
    var subscriptions: Set<AnyCancellable> = []
    @Published var isValidToTweet: Bool = false
    @Published var shouldDismissComposer: Bool = false
    @Published var error: String?
    @Published var user: TwitterUser?
    var tweetContent: String = ""
    
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
    
    func validateTweetContent() {
        isValidToTweet = !tweetContent.isEmpty
    }
    
    func sendTweet() {
        guard let userID = user?.id, let user else { return }
        let tweet = Tweet(author: user, authorID: userID, tweetContent: tweetContent, likesCount: 0, likers: [], isReply: false, parentReference: nil, timestamp: Date())
        databaseManager.sendTweet(tweet: tweet)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] state in
                self?.shouldDismissComposer = state
            }
            .store(in: &subscriptions)

    }
}
