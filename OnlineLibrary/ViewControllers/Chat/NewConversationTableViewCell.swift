//
//  NewConversationTableViewCell.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//

import Foundation
import SDWebImage

class NewConversationTableViewCell: UITableViewCell {
    static let identifier = "NewConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let firestoreManager = FirestoreManager()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame = CGRect(x: 10, y: 10, width: 350, height: 100)
        contentView.frame = CGRect(x: 0, y: 0, width: 350, height: 100)
        userImageView.frame = CGRect(x: 10, y: 0, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: Int(userImageView.right) + 10, y: 10, width: Int(contentView.width - 20 - userImageView.width), height: Int((contentView.height - 20)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: SearchResult) {
        userNameLabel.text = model.name
        var newOtherUserEmail = ""
        var counter = 0
        for ch in model.email {
            if ch == "-" {
                if counter == 0 {
                    newOtherUserEmail.append("@")
                } else {
                    newOtherUserEmail.append(".")
                }
                counter += 1
            } else {
                newOtherUserEmail.append(ch)
            }
        }
        firestoreManager.checkForUserExisting(email: newOtherUserEmail, { [weak self] exists in
            if exists {
                self?.firestoreManager.getUserInfo(email: newOtherUserEmail, completion: { user in
                    let username = user.username
                    let path = "images.\(username)_Avatar.png"
                    StorageManager.shared.downloadURL(for: path, completion: {[weak self] res in
                        switch res {
                        case .success(let res):
                            DispatchQueue.main.async {
                                self?.userImageView.sd_setImage(with: res)
                            }
                        case .failure(let err):
                            print(err)
                        }
                    })
                })
            } else {
                self?.firestoreManager.checkForBookstoreExisting(email: newOtherUserEmail, { exists in
                    if exists {
                        self?.firestoreManager.getBookstoreDataWithEmail(email: newOtherUserEmail, completion: { bookstore in
                            let bookstoreName = bookstore.name
                            let path = "images.\(bookstoreName)_Avatar.png"
                            StorageManager.shared.downloadURL(for: path, completion: {[weak self] res in
                                switch res {
                                case .success(let res):
                                    DispatchQueue.main.async {
                                        self?.userImageView.sd_setImage(with: res)
                                    }
                                case .failure(let err):
                                    print(err)
                                }
                            })
                        })
                    }
                })
            }
        })
    }
}
