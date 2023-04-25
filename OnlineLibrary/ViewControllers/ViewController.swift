//
//  ViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

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
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        checkConnection()
        greetingViewSettings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateSignIn()
    }
    
    // MARK: Private functions
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
            guard let navVc = storyboard?.instantiateViewController(withIdentifier: "signNavVc") as? UINavigationController else { return }
            UIApplication.shared.keyWindow?.rootViewController = navVc
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
        if appDelegate().currentUser?.email != nil {
            guard let email = appDelegate().currentEmail else { return }
            
            firestoreManager.getUsersApplications(email: email, completion: {[weak self] arr in
                self?.firestoreManager.downloadUserAvatar(email: email, completion: { image in
                    DispatchQueue.main.async {[weak self] in
                        let vc: UserProfileViewController = self?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                        
                        vc.currentImage = image
                        vc.arr = arr
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    }
                })
                
            })
        } else if appDelegate().currentBookstoreOwner != nil {
            let tabBC: UITabBarController = storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
            let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
            let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
            
            let applicationsVC = nav_1.topViewController as! ApplicationsListViewController
            let favouritesVC = nav_2.topViewController as! FavouritesViewController
            
            guard let email = appDelegate().currentEmail else { return }
            
            firestoreManager.getRecommendedBooks(email: email, completion: {[weak self] arr in
                self?.firestoreManager.configureRandomBooksOfRandomGenre(email: email, completion: { randArr in
                    self?.firestoreManager.configureRecentlyAddedBooks(email: email, completion: { recentlyAddedArr in
                        self?.firestoreManager.getApplications(email: email, completion: { appls in
                            favouritesVC.recommendedBooksArr = arr
                            favouritesVC.randomBooksArr = randArr
                            favouritesVC.recentlyAddedBooksArr = recentlyAddedArr
                            
                            applicationsVC.applicationsArr = appls
                            
                            
                            UIApplication.shared.keyWindow?.rootViewController = tabBC
                        })
                    })
                })
            })
        }
    }
}



