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
    func retrieveUser()
}

final class ProfileViewViewModel: ObservableObject, ProfileViewViewModelDelegate {
    var subscriptions: Set<AnyCancellable> = []
    @Published var user: TwitterUser?
    @Published var error: String?
    
    let databaseManager: DatabaseManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    
    func retrieveUser() {
        guard let id = Auth.auth().getUserID() else { return }
        
        databaseManager.retrieveUser(with: id)
            .sink {[weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: {[weak self] user in
                print(user)
                self?.user = user
            }
            .store(in: &subscriptions)

    }
}
