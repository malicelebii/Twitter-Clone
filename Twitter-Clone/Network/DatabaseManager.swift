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
}

final class DatabaseManager: DatabaseManagerDelegate {
    static let shared = DatabaseManager()
    
    let db = Firestore.firestore()
    let usersPath: String = "users"
    
    func addUser(with user: User) -> AnyPublisher<Bool, Error> {
        let twitterUser = TwitterUser(from: user)
        return db.collection(usersPath).document(twitterUser.id).setData(from: twitterUser)
            .map { _ in
                return true
            }
            .eraseToAnyPublisher()
    }
}
