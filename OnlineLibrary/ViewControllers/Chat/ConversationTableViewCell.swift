//
//  ConversationTableViewCell.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"
    private let firestoreManager = FirestoreManager()

    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userMessageLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var sentMessageImageView: UIImageView!
    
    func configure(with model: Conversation) {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = height/2
        userImageView.layer.masksToBounds = true
        userImageView.layer.borderColor = UIColor.lightGray.cgColor
        userImageView.layer.borderWidth = 1
        
        sentMessageImageView.contentMode = .scaleAspectFill
        
        sentMessageImageView.layer.cornerRadius = 10
        sentMessageImageView.layer.masksToBounds = true
        
        if model.latestMessage.message.contains("https://") && model.latestMessage.message.contains("video") {
            userMessageLabel.text = "Video"
        } else if model.latestMessage.message.contains("https://") {
             userMessageLabel.text = "Photo"
             sentMessageImageView.isHidden = false
             guard let url = URL(string: model.latestMessage.message) else { return }
             URLSession.shared.dataTask(with: url, completionHandler: { [weak self] res, _, err in
                 guard let data = res, err == nil else { return }
                 DispatchQueue.main.async {
                     let image = UIImage(data: data)
                     self?.sentMessageImageView.image = image
                 }
             }).resume()
        } else {
            userMessageLabel.text = model.latestMessage.message
            sentMessageImageView.isHidden = true
        }
        
        lastMessageDateLabel.text = model.latestMessage.date
        lastMessageDateLabel.text = lastMessageDateLabel.text?.replacingOccurrences(of: "_", with: "-")
        userNameLabel.text = model.name
        userNameLabel.textColor = .black
        
        let otherUserEmail = model.otherUserEmail
        var newOtherUserEmail = ""
        var counter = 0
        for ch in otherUserEmail {
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
                    let path = "images.\(user.username)_Avatar.png"
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
                            let path = "images.\(bookstore.name)_Avatar.png"
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
        
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.65
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = height/2
            blurView.layer.borderWidth = 1.5
            blurView.layer.borderColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1).cgColor
            blurView.backgroundColor = .systemBrown
            blurView.clipsToBounds = true
            return blurView
        }()
        
        let selectedBackgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = height/2
            blurView.layer.borderWidth = 1.5
            blurView.layer.borderColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1).cgColor
            blurView.backgroundColor = .systemBrown
            blurView.clipsToBounds = true
            return blurView
        }()
        
        backgroundView = backgroundBlur
        selectedBackgroundView?.backgroundColor = .clear
        selectedBackgroundView = selectedBackgroundBlur
    }
}

