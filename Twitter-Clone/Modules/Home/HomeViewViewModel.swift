//
//  HomeViewViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 4.09.2024.
//

import UIKit
import FirebaseAuth

protocol HomeViewViewModelDelegate {
    func handleAuthentication(completion: (UIViewController) -> Void)
    func signOut()
}

final class HomeViewViewModel: HomeViewViewModelDelegate {
    let authManager: AuthManagerDelegate
    
    init(authManager: AuthManagerDelegate = AuthManager.shared) {
        self.authManager = authManager
    }
    
    func handleAuthentication(completion: (UIViewController) -> Void) {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: OnboardingViewController())
            vc.modalPresentationStyle = .fullScreen
            completion(vc)
        }
    }
    
    func signOut() {
        authManager.signOut()
    }
}
