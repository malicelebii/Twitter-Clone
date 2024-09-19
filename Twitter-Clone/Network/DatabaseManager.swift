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
    func retrieveTweets(authorID: String) -> AnyPublisher<[Tweet], Error>
    func search(with query: String) -> AnyPublisher<[TwitterUser], Error>
    func follow(follower: String, following: String) -> AnyPublisher<Bool, Error>
    func unFollow(follower: String, following: String) -> AnyPublisher<Bool, Error>
    func isFollowing(follower: String, following: String) -> AnyPublisher<Bool, Error>
    func getFollowings(for userID: String) -> AnyPublisher<[String], Error>
    func retrieveTweetsForUsers(userIDs: [String]) -> AnyPublisher<[Tweet], Error>
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
    
    func retrieveTweets(authorID: String) -> AnyPublisher<[Tweet], Error> {
        db.collection(tweetsPath).whereField("authorID", isEqualTo: authorID)
            .order(by: "timestamp", descending: true)
            .getDocuments()
            .tryMap (\.documents)
            .tryMap { snapShots in
                try snapShots.map({
                    try $0.data(as: Tweet.self)
                })
            }
            .eraseToAnyPublisher()
    }
    
    func getFollowings(for userID: String) -> AnyPublisher<[String], Error> {
           db.collection("followings").whereField("follower", isEqualTo: userID)
               .getDocuments()
               .tryMap(\.documents)
               .tryMap { snapShots in
                   try snapShots.compactMap { snapshot -> String? in
                       let data = try snapshot.data(as: [String: String].self)
                       return data["following"]
                   }
               }
               .eraseToAnyPublisher()
    }
    
    func retrieveTweetsForUsers(userIDs: [String]) -> AnyPublisher<[Tweet], Error> {
         return db.collection(tweetsPath)
             .whereField("authorID", in: userIDs)
             .order(by: "timestamp", descending: true)
             .getDocuments()
             .tryMap(\.documents)
             .tryMap { snapshots in
                 try snapshots.map {
                     try $0.data(as: Tweet.self)
                 }
             }
             .eraseToAnyPublisher()
     }
    
    func search(with query: String) -> AnyPublisher<[TwitterUser], Error> {
        db.collection(usersPath).whereField("username", isEqualTo: query)
            .getDocuments()
            .map(\.documents)
            .tryMap { snapShots in
                try snapShots.map {
                    try $0.data(as: TwitterUser.self)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func follow(follower: String, following: String) -> AnyPublisher<Bool, Error> {
        let randomID = UUID().uuidString
        let data = [
            "follower": follower,
            "following": following
        ]
        db.collection(usersPath).document(follower).updateData(["followingCount": FieldValue.increment(Int64(1))])
        db.collection(usersPath).document(following).updateData(["followersCount": FieldValue.increment(Int64(1))])
        return db.collection("followings").document(randomID).setData(data)
            .map { _ in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func unFollow(follower: String, following: String) -> AnyPublisher<Bool, Error> {
        db.collection(usersPath).document(follower).updateData(["followingCount": FieldValue.increment(Int64(-1))])
        db.collection(usersPath).document(following).updateData(["followersCount": FieldValue.increment(Int64(-1))])
        
        return db.collection("followings").whereField("follower", isEqualTo: follower).whereField("following", isEqualTo: following)
            .getDocuments()
            .map(\.documents.first)
            .map { query in
                query?.reference.delete(completion: nil)
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func isFollowing(follower: String, following: String) -> AnyPublisher<Bool, Error> {
        db.collection("followings").whereField("follower", isEqualTo: follower).whereField("following", isEqualTo: following)
            .getDocuments()
            .map(\.count)
            .map { count in
                return count == 0 ? false : true
            }
            .eraseToAnyPublisher()
    }
}
