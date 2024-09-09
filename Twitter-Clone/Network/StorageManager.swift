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
    func getDownloadURL(for id: String?) -> AnyPublisher<URL, Error>
}

final class StorageManager: StorageManagerDelegate {
    static let shared = StorageManager()
    
    let storage = Storage.storage()
    
    func uploadProfilePhoto(with randomID: String, image: Data, metaData: StorageMetadata) -> AnyPublisher<StorageMetadata, Error> {
        storage
            .reference()
            .child("images/\(randomID).jpg")
            .putData(image, metadata: metaData)
            .eraseToAnyPublisher()
    }
    
    func getDownloadURL(for id: String?) -> AnyPublisher<URL, Error> {
        guard let id = id else {
            return Fail(error: FirebaseStorageError.invalidImageID)
            .eraseToAnyPublisher() }
        
        return storage
            .reference(withPath: id)
            .downloadURL()
            .eraseToAnyPublisher()
    }
}


enum FirebaseStorageError: Error {
    case invalidImageID
}
