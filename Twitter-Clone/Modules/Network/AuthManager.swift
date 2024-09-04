//
//  AuthManager.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 4.09.2024.
//

import Foundation
import FirebaseAuthCombineSwift
import Combine
import FirebaseAuth

protocol AuthManagerDelegate {
    func createUser(email: String, password: String) -> AnyPublisher<User, Error>
    func signOut()
}

final class AuthManager: AuthManagerDelegate {
    static let shared = AuthManager()
    
    func createUser(email: String, password: String) -> AnyPublisher<FirebaseAuth.User, Error> {
        return  Auth.auth().createUser(withEmail: email, password: password)
            .map(\.user)
            .eraseToAnyPublisher()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
    }
}
