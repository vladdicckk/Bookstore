//
//  ChatProfileViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 07.04.2023.
//

import UIKit

class ChatProfileViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var chatProfileImageURL: URL?
    var bookstore: Bookstore?
    var user: User?
    let firestoreManager = FirestoreManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChatProfileCell")
        view.backgroundColor = .clear
        tableView.backgroundColor = .clear
        imageViewSettings() 
        configureViewBlur()
        setProfilePic()
    }
    
    private func imageViewSettings() {
        profileImageView.layer.cornerRadius = profileImageView.height/2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
        profileImageView.layer.borderWidth = 2
    }
    
    private func setProfilePic() {
        guard let chatProfileImageURL = chatProfileImageURL else { return }
        URLSession.shared.dataTask(with: chatProfileImageURL) { (data, response, error) in
            // Error handling...
            guard let imageData = data else { return }
            
            DispatchQueue.main.async {
                self.profileImageView.image = UIImage(data: imageData)
            }
        }.resume()
    }
    
    private func configureViewBlur() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 1
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        view.addSubview(backgroundBlur)
        view.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ChatProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if bookstore?.name != nil && bookstore?.name != "" {
            return 2
        }
        
        if bookstore?.ownersName != nil && bookstore?.ownersName != "" {
            return 2
        }
        
        if user?.username != nil && user?.firstName != nil && user?.lastName != nil && user?.age != nil && user?.username != "" && user?.lastName != nil && user?.age != 1 && user?.firstName != "" && user?.lastName != "" {
            return 5
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatProfileCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 2
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 18
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        cell.layer.borderColor = UIColor.systemBrown.cgColor
        cell.layer.borderWidth = 2.0
        
        cell.backgroundColor = .clear
        cell.layer.cornerRadius = 16
        cell.backgroundView = backgroundBlur
        cell.selectedBackgroundView = cell.backgroundView
        
        if bookstore?.name != nil && bookstore?.name != "" {
            if indexPath.row == 0 {
                content.text = "Bookstore name: \(bookstore?.name ?? "")"
            } else if indexPath.row == 1 {
                content.text = "Open profile"
            }
        }
        
        if bookstore?.ownersName != nil && bookstore?.ownersName != "" && bookstore?.name != nil && bookstore?.name != "" {
            if indexPath.row == 0 {
                content.text = "Bookstore name: \(bookstore?.name ?? "")"
            } else if indexPath.row == 1 {
                content.text = "Owners name: \(bookstore?.ownersName ?? "")"
            } else if indexPath.row == 2 {
                content.text = "Open profile"
            }
        }
        
        if user?.username != nil && user?.firstName != nil && user?.lastName != nil && user?.age != nil && user?.username != "" && user?.lastName != nil && user?.age != 1 && user?.firstName != "" && user?.lastName != "" {
            if indexPath.row == 0 {
                content.text = "Name: \(user?.firstName ?? "")"
            } else if indexPath.row == 1 {
                content.text = "Surname: \(user?.lastName ?? "")"
            } else if indexPath.row == 2 {
                content.text = "Age: \(user?.age ?? 0)"
            } else if indexPath.row == 3 {
                content.text = "Username: \(user?.username ?? "")"
            } else if indexPath.row == 4 {
                content.text = "Open profile"
            }
        }
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let visibleRows = tableView.indexPathsForVisibleRows, let lastRow = visibleRows.last, lastRow == indexPath {
            if tableView.numberOfRows(inSection: 0) > 3 {
                print("Open user profile")
                guard let email = user?.email else { return }
                firestoreManager.getUsersApplications(email: email, completion: {[weak self] arr in
                    self?.firestoreManager.downloadUserAvatar(email: email, completion: { image in
                        DispatchQueue.main.async {[weak self] in
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc: UserProfileViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                            
                            vc.currentImage = image
                            vc.email = self?.user?.email
                            vc.firstName = self?.user?.firstName
                            vc.lastName = self?.user?.lastName
                            vc.age = self?.user?.age
                            vc.username = self?.user?.username
                            vc.phoneNumber = self?.user?.phoneNumber
                            vc.address = self?.user?.location
                            vc.arr = arr
                            self?.appDelegate().currentReviewingUsersProfile = self?.user
                            vc.reviewingChatProfileText = "To chats"
                            UIApplication.shared.keyWindow?.rootViewController = vc
                            //self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                })
            } else if tableView.numberOfRows(inSection: 0) <= 3 {
                print("Open bookstore profile")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBC: UITabBarController = storyBoard.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
                let nav = tabBC.viewControllers?[0] as! UINavigationController
                let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
                let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
                
                let bookstoreVC = nav.topViewController as! LibraryViewController
                let applicationsVC = nav_1.topViewController as! ApplicationsListViewController
                let favouritesVC = nav_2.topViewController as! FavouritesViewController
                
                guard let owner = bookstore else { return }
                firestoreManager.getRecommendedBooks(email: owner.email, completion: {[weak self] arr in
                    self?.firestoreManager.configureRandomBooksOfRandomGenre(email: owner.email, completion: { randArr in
                        self?.firestoreManager.configureRecentlyAddedBooks(email: owner.email, completion: { recentlyAddedArr in
                            self?.firestoreManager.getApplications(email: owner.email, completion: { appls in
                                favouritesVC.recommendedBooksArr = arr
                                favouritesVC.randomBooksArr = randArr
                                favouritesVC.recentlyAddedBooksArr = recentlyAddedArr
                                
                                applicationsVC.applicationsArr = appls
                                
                                bookstoreVC.phoneNumber = owner.phoneNumber
                                bookstoreVC.address = owner.location
                                bookstoreVC.bookstoreName = owner.name
                                bookstoreVC.preference = owner.preference
                                bookstoreVC.email = owner.email
                                bookstoreVC.bookstoreOwnersName = owner.ownersName
                                bookstoreVC.additionalInfoText = owner.additionalInfo
                                bookstoreVC.reviewingChatProfileText = "To chats"
                                
                                self?.appDelegate().currentReviewingOwnersProfile = owner
                                UIApplication.shared.keyWindow?.rootViewController = tabBC
                            })
                        })
                    })
                })
            }
        }
    }
}
