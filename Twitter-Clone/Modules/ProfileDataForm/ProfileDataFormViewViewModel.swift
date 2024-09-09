//
//  ProfileDataFormViewViewModel.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 9.09.2024.
//

import UIKit
import FirebaseStorage
import Combine

protocol ProfileDataFormViewViewModelDelegate {
    func validateUserProfileForm()
    func uploadAvatar()
}

final class ProfileDataFormViewViewModel: ObservableObject, ProfileDataFormViewViewModelDelegate {
    var subscriptions: Set<AnyCancellable> = []
    @Published var displayName: String?
    @Published var username: String?
    @Published var bio: String?
    @Published var avatarPath: String?
    @Published var imageData: UIImage?
    @Published var isFormValid: Bool = false
    @Published var url: URL?
    @Published var error: String?
    
    let storageManager: StorageManagerDelegate
    
    init(storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.storageManager = storageManager
    }
    
    func validateUserProfileForm() {
        guard let displayName, let username, username.count > 2, let bio, bio.count > 2, imageData != nil, displayName.count > 2 else { isFormValid = false ; return }
        isFormValid = true
    }
    
    func uploadAvatar() {
        let randomID = UUID().uuidString
        guard let imageData = imageData?.jpegData(compressionQuality: 0.5) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageManager.uploadProfilePhoto(with: randomID, image: imageData, metaData: metaData)
            .flatMap({ metaData in
                self.storageManager.getDownloadURL(for: metaData.path)
                        })
                        .sink { [weak self] completion in
                            
                            switch completion {
                            case .failure(let error):
                                print(error.localizedDescription)
                                self?.error = error.localizedDescription
                            
                            case .finished:
                                1

                            }
                            
                        } receiveValue: { [weak self] url in
                            self?.avatarPath = url.absoluteString
                        }
                        .store(in: &subscriptions)

    }
}
