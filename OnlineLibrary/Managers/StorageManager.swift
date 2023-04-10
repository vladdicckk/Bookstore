//
//  StorageManager.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//

import UIKit
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    public typealias UploadURLCompletion = (Result<URL, Error>) -> Void
    
    func uploadProfilePic(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, completion: { [weak self] res, err in
            guard err == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return }
            self?.storage.child("images.\(fileName)_Avatar").downloadURL(completion: { res, err in
                guard let res = res else {
                    print("err to get url")
                    completion(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                let urlString = res.absoluteString
                completion(.success(urlString))
            })
        })
    }
    
    func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, completion: { [weak self] res, err in
            guard err == nil else {
                completion(.failure(StorageErrors.failedToUpload))
                return }
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { res, err in
                guard let res = res else {
                    print("err to get url")
                    completion(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                
                let urlString = res.absoluteString
                completion(.success(urlString))
            })
        })
    }
    
    func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        DispatchQueue.main.async {
            self.storage.child("message_videos/\(fileName)").putFile(from: fileUrl, completion: { [weak self] res, err in
                guard err == nil else {
                    print("Video uploading err")
                    completion(.failure(StorageErrors.failedToUpload))
                    return }
                self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { res, err in
                    guard let res = res else {
                        print("err to get url")
                        completion(.failure(StorageErrors.failedToDownloadURL))
                        return
                    }
                    
                    let urlString = res.absoluteString
                    completion(.success(urlString))
                })
            })
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToDownloadURL
    }
    
    func downloadURL(for path: String, completion: @escaping UploadURLCompletion) {
        let ref = storage.child(path)
        ref.downloadURL(completion: { res, err in
            guard let url = res, err == nil else {
                completion(.failure(StorageErrors.failedToDownloadURL))
                return }
            completion(.success(url))
        })
    }
}

