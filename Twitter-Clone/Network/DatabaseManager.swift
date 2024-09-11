//
//  DatabaseManager.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 6.09.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestoreCombineSwift
import FirebaseFirestore
import Combine

protocol DatabaseManagerDelegate {
    func addUser(with user: User) -> AnyPublisher<Bool, Error>
    func retrieveUser(with id: String) -> AnyPublisher<TwitterUser, Error>
    func updateUserFields(fields: [String: Any], for id: String) -> AnyPublisher<Bool, Error>
    func sendTweet(tweet: Tweet) -> AnyPublisher<Bool, Error>
}

final class DatabaseManager: DatabaseManagerDelegate {
    static let shared = DatabaseManager()
    
    let db = Firestore.firestore()
    let usersPath: String = "users"
    let tweetsPath: String = "tweets"
    
    func addUser(with user: User) -> AnyPublisher<Bool, Error> {
        let twitterUser = TwitterUser(from: user)
        return db.collection(usersPath).document(twitterUser.id).setData(from: twitterUser)
            .map { _ in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func retrieveUser(with id: String) -> AnyPublisher<TwitterUser, Error> {
        db.collection(usersPath).document(id).getDocument()
            .tryMap {
                try $0.data(as: TwitterUser.self)
            }
            .eraseToAnyPublisher()
    }
    
    func updateUserFields(fields: [String : Any], for id: String) -> AnyPublisher<Bool, Error> {
        db.collection(usersPath).document(id).updateData(fields)
            .map { _ in true }
            .eraseToAnyPublisher()
    }
    
    func sendTweet(tweet: Tweet) -> AnyPublisher<Bool, Error> {
        db.collection(tweetsPath).document(tweet.id).setData(from: tweet)
            .map { _ in true}
            .eraseToAnyPublisher()
    }
}
