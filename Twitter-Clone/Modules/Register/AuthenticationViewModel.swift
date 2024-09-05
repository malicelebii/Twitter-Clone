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
}

final class AuthenticationViewModel: ObservableObject, AuthenticationViewModelDelegate {
    @Published var email: String?
    @Published var password: String?
    @Published var isAuthenticationFormValid: Bool = false
    @Published var user: User?
    var subscriptions: Set<AnyCancellable> = []
    let authManager: AuthManagerDelegate
    
    init(authManager: AuthManagerDelegate = AuthManager.shared) {
        self.authManager = authManager
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
            .sink { _ in
                
            } receiveValue: { [weak self] user in
                self?.user = user
            }
            .store(in: &subscriptions)
    }
}
