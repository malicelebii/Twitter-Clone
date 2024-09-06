//
//  RegisterViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 3.09.2024.
//

import Foundation
import FirebaseAuth
import Combine

protocol AuthenticationViewModelDelegate {
    func validateRegistrationForm()
    func isValidEmail(_ email: String) -> Bool
    func createUser()
    func login()
}

final class AuthenticationViewModel: ObservableObject, AuthenticationViewModelDelegate {
    @Published var email: String?
    @Published var password: String?
    @Published var isAuthenticationFormValid: Bool = false
    @Published var user: User?
    @Published var error: String?
    
    var subscriptions: Set<AnyCancellable> = []
    let authManager: AuthManagerDelegate
    let databaseManager: DatabaseManagerDelegate
    
    init(authManager: AuthManagerDelegate = AuthManager.shared, databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.authManager = authManager
        self.databaseManager = databaseManager
    }
    
    func validateRegistrationForm() {
        guard let email = email, let password = password else { return }
        isAuthenticationFormValid = isValidEmail(email) && password.count >= 8
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func createUser() {
        guard let email = email, let password = password else { return }
        authManager.createUser(email: email, password: password)
            .handleEvents(receiveOutput: {[weak self] user in
                self?.user = user
            })
            .sink { _ in
                
            } receiveValue: { [weak self] user in
                self?.createRecord(for: user)
            }
            .store(in: &subscriptions)
    }
    
    func createRecord(for user: User) {
        databaseManager.addUser(with: user)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { state in
                print("Adding user record to database: \(state)")
            }
            .store(in: &subscriptions)

    }
    
    func login() {
        guard let email = email, let password = password else { return }
        authManager.login(email: email, password: password)
            .sink {[weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.error = error.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: {[weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions)
    }
}
