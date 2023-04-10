//
//  ChatsViewController.swift
//  Pods
//
//  Created by iosdev on 05.04.2023.
//

import UIKit
import MessageKit

struct Conversation {
    let id: String
    let name: String
    let latestMessage: LatestMessage
    let otherUserEmail: String
}

struct LatestMessage {
    let date: String
    let isRead: Bool
    let message: String
}

private enum UserType {
    case client
    case bookstore
}

private enum Result<User, Bookstore> {
    case client(User)
    case bookstore(Bookstore)
}

class ChatsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var conversations: [Conversation]?
    var application: Application?
    
    private let firestoreManager = FirestoreManager()
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations"
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "chatsBackground") ?? UIImage())
        tableView.backgroundColor = .clear
        let rightButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        rightButton.style = .done
        navigationItem.rightBarButtonItem = rightButton
        let leftButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(toStart))
        leftButton.style = .done
        navigationItem.leftBarButtonItem = leftButton
        view.addSubview(noConversationsLabel)
        configureViewBlur()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let tempEmail: String?
        if appDelegate().currentUser != nil {
            tempEmail = appDelegate().currentUser?.email
        } else {
            tempEmail = appDelegate().currentBookstoreOwner?.email
        }
        guard let email = tempEmail else { return }
        
        let safeEmail = FirebaseManager.safeEmail(email: email)
        FirebaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] res in
            switch res {
            case .success(let convs):
                self?.conversations = convs
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        })
        
        tableView.reloadData()
        tabBarController?.tabBar.isHidden = false
        setupHandlers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noConversationsLabel.frame = CGRect(x: 10, y: (Int(view.height) - 100)/2, width: Int(view.width) - 20, height: 100)
    }
    
    private func configureViewBlur() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.prominent)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.4
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
    
    private func fetchActualUserInfo(userType: UserType, dataCompletion: @escaping (Result<User, Bookstore>) -> Void) {
        switch userType {
        case .bookstore:
            guard let name = appDelegate().currentBookstoreOwner?.name else { return }
            firestoreManager.getBookstoreData(name: name, completion: { bookstore in
                dataCompletion(.bookstore(bookstore))
            })
        case .client:
            guard let email = appDelegate().currentUser?.email else { return }
            firestoreManager.getUserInfo(email: email, completion: { user in
                dataCompletion(.client(user))
            })
        }
    }
    
    @objc private func didTapComposeButton() {
        let tempEmail: String?
        if appDelegate().currentUser != nil {
            tempEmail = appDelegate().currentUser?.email
        } else {
            tempEmail = appDelegate().currentBookstoreOwner?.email
        }
        guard let email = tempEmail else { return }
        
        let vc = NewConversationViewController()
        vc.completion = { [weak self] res in
            self?.createNewConversation(result: res)
        }
        FirebaseManager.shared.getUsersConversationsEmails(email: email, completion: { [weak self]  res in
            vc.emails = res
            let navVC = UINavigationController(rootViewController: vc)
            self?.present(navVC, animated: true)
        })
    }
    
    @objc private func toStart() {
        if appDelegate().currentUser != nil {
            fetchActualUserInfo(userType: .client, dataCompletion: { [weak self] res in
                switch res {
                case .client(let client):
                    self?.appDelegate().currentUser = client
                default:
                    break
                }
                guard let user = self?.appDelegate().currentUser else { return }
                self?.firestoreManager.getUsersApplications(email: user.email, completion: {[weak self] arr in
                    self?.firestoreManager.downloadUserAvatar(email: user.email, completion: { image in
                        DispatchQueue.main.async {[weak self] in
                            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc: UserProfileViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                            
                            vc.currentImage = image
                            vc.email = user.email
                            vc.firstName = user.firstName
                            vc.lastName = user.lastName
                            vc.age = user.age
                            vc.username = user.username
                            vc.phoneNumber = user.phoneNumber
                            vc.address = user.location
                            vc.arr = arr
                            self?.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                })
            })
        } else if appDelegate().currentBookstoreOwner != nil {
            fetchActualUserInfo(userType: .bookstore, dataCompletion: { [weak self] res in
                switch res {
                case .bookstore(let bookstore):
                    self?.appDelegate().currentBookstoreOwner = bookstore
                default:
                    break
                }
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBC: UITabBarController = storyBoard.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
                let nav = tabBC.viewControllers?[0] as! UINavigationController
                let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
                let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
                
                let bookstoreVC = nav.topViewController as! LibraryViewController
                let applicationsVC = nav_1.topViewController as! ApplicationsListViewController
                let favouritesVC = nav_2.topViewController as! FavouritesViewController
                
                guard let owner = self?.appDelegate().currentBookstoreOwner else { return }
                self?.firestoreManager.getRecommendedBooks(email: owner.email, completion: {[weak self] arr in
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
                                
                                UIApplication.shared.keyWindow?.rootViewController = tabBC
                            })
                        })
                    })
                })
            })
        } else {
            print("Current user nil")
        }
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = result.email
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.application = application
        self.application = nil
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - fix id error
    private func setupHandlers() {
        guard let application = application else {
            print("application nil")
            return
        }
        let senderEmail = application.user.email
        let senderSafeEmail = FirebaseManager.safeEmail(email: senderEmail)
        
        var convFound = false
        
        let recipientEmail = application.bookstore.email
        let recipientSafeEmail = FirebaseManager.safeEmail(email: recipientEmail)
        
        let id_1 = "conversation_\(senderSafeEmail)_\(recipientSafeEmail)"
        let id_2 = "conversation_\(recipientSafeEmail)_\(senderSafeEmail)"
        
        if let conversations = conversations {
            for conversation in conversations {
                if conversation.id == id_1 {
                    convFound = true
                    let vc = ChatViewController(with: application.bookstore.email, id: id_1)
                    if application.bookstore.ownersName  != "" {
                        vc.title = application.bookstore.ownersName
                    } else {
                        vc.title = application.bookstore.name
                    }
                    
                    vc.application = application
                    vc.navigationItem.largeTitleDisplayMode = .never
                    self.application = nil
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        
        if !convFound {
            if let conversations = conversations {
                for conversation in conversations {
                    if conversation.id == id_2 {
                        convFound = true
                        let vc = ChatViewController(with: application.bookstore.email, id: id_2)
                        if application.bookstore.ownersName != "" || application.bookstore.ownersName != "Set your name" {
                            vc.title = application.bookstore.ownersName
                        } else {
                            vc.title = application.bookstore.name
                        }
                        
                        vc.application = application
                        vc.navigationItem.largeTitleDisplayMode = .never
                        self.application = nil
                        navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
        if !convFound {
            createNewConversation(result: SearchResult(name: application.bookstore.ownersName, email: recipientSafeEmail, bookstoreName: application.bookstore.name, username: application.user.username))
        } else {
            print("Conv found")
        }
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        guard let model = conversations?[indexPath.row] else { return cell }
        
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.selectedBackgroundView?.layer.cornerRadius = 16
        cell.layer.cornerRadius = 16
        cell.backgroundColor = .clear
        cell.selectionStyle = .blue
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = conversations?[indexPath.row] else { return }
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
