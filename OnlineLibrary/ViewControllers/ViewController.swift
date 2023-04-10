//
//  ViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

private enum UserType {
    case client
    case bookstore
}

private enum Result<User, Bookstore> {
    case client(User)
    case bookstore(Bookstore)
}

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var homeButton: UIButton!
    
    // MARK: Parameters
    let database = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    let monitor = NetworkMonitor()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkConnection()
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        greetingViewSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateSignIn()
    }
    
    // MARK: Private functions
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
    
    private func checkConnection() {
        monitor.startMonitoring(completion: {[weak self] isConnected in
            if !isConnected {
                DispatchQueue.main.async {
                    self?.showConnectionErrorAlert()
                }
            }
        })
        monitor.stopMonitoring()
    }
    
    private func validateSignIn() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") else { return }
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        } else if appDelegate().currentUser == nil && appDelegate().currentBookstoreOwner == nil {
            firestoreManager.checkForUserExisting(email: FirebaseAuth.Auth.auth().currentUser?.email ?? "", { [ weak self ] exists in
                if exists {
                    self?.firestoreManager.getUserInfo(email: FirebaseAuth.Auth.auth().currentUser?.email ?? "", completion: { user in
                        self?.appDelegate().currentUser = user
                    })
                } else {
                    self?.firestoreManager.getBookstoreDataWithEmail(email: FirebaseAuth.Auth.auth().currentUser?.email ?? "", completion: { bookstore in
                        self?.appDelegate().currentBookstoreOwner = bookstore
                    })
                }
            })
        }
    }
    
    private func showConnectionErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Connection failed, try again later", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Exit", style: .default, handler: {(action: UIAlertAction) in
            exit(0)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func greetingViewSettings() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.75
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        greetingView.setCorner(radius: 18)
        greetingView.layer.borderWidth = 1
        greetingView.layer.borderColor = UIColor.black.cgColor
        greetingView.backgroundColor = .clear
        greetingView.addSubview(backgroundBlur)
        greetingView.sendSubviewToBack(backgroundBlur)
        
        backgroundBlurConstraints(blur: backgroundBlur)
    }
    
    private func backgroundBlurConstraints(blur: UIVisualEffectView) {
        blur.topAnchor.constraint(equalTo: greetingView.topAnchor, constant: 0).isActive = true
        blur.leadingAnchor.constraint(equalTo: greetingView.leadingAnchor, constant: 0).isActive = true
        blur.trailingAnchor.constraint(equalTo: greetingView.trailingAnchor, constant: 0).isActive = true
        blur.bottomAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: 0).isActive = true
    }
    
    private func getNamesData(completion: @escaping ([String]) -> ()) {
        database.collection("Owners").getDocuments() { (querySnapshot, err) in
            guard let querySnapshot = querySnapshot else { return }
            var arr: [String] = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot.documents {
                    arr.append("\(document.get("name") ?? "")")
                }
                completion(arr)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func toLibrariesButtonTapped(_ sender: Any) {
        let vc: LibrariesViewController = self.storyboard?.instantiateViewController(withIdentifier: "LibrariesViewController") as! LibrariesViewController
        getNamesData(completion: { arr in
            vc.bookStoreTitlesTemp = arr
            vc.bookStoreTitles = arr
            let navVc = UINavigationController(rootViewController: vc)
            UIApplication.shared.keyWindow?.rootViewController = navVc
        })
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        sleep(UInt32(0.3))
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
                            let vc: UserProfileViewController = self?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                            
                            vc.currentImage = image
                            vc.email = user.email
                            vc.firstName = user.firstName
                            vc.lastName = user.lastName
                            vc.age = user.age
                            vc.username = user.username
                            vc.phoneNumber = user.phoneNumber
                            vc.address = user.location
                            vc.arr = arr
                            UIApplication.shared.keyWindow?.rootViewController = vc
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
                let tabBC: UITabBarController = self?.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
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
}



