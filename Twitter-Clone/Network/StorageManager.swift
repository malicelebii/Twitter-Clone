//
//  StorageManager.swift
//  Twitter-Clone
//
//  Created by Mehmet Ali ÇELEBİ on 9.09.2024.
//

import Foundation
import Combine
import FirebaseStorageCombineSwift
import FirebaseStorage

protocol StorageManagerDelegate {
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error>
}

final class StorageManager: StorageManagerDelegate {
    static let shared = StorageManager()
    
    let storage = Storage.storage().reference()
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error> {
        storage
            .child("images/\(randomID)/.jpg")
            .putData(image, metadata: metaData)
            .eraseToAnyPublisher()
    }
}
