//
//  ProfileDataFormViewViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 9.09.2024.
//

import UIKit

protocol ProfileDataFormViewViewModelDelegate {
    func validateUserProfileForm()
    func uploadAvatar()
}

final class ProfileDataFormViewViewModel: ObservableObject, ProfileDataFormViewViewModelDelegate {
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
    @Published var imageData: UIImage?
    @Published var isFormValid: Bool = false
    
    let storageManager: StorageManagerDelegate
    
    init(storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.storageManager = storageManager
    }
    
    func validateUserProfileForm() {
        guard let displayName, let username, username.count > 2, let bio, bio.count > 2, imageData != nil, displayName.count > 2 else { isFormValid = false ; return }
        isFormValid = true
    }
}
