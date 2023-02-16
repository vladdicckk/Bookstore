//
//  ViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var homeButton: UIButton!
    
    // MARK: Parameters
    let database = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        greetingViewSettings()
        
        if appDelegate().currentUser == nil && appDelegate().currentBookstoreOwner == nil {
            homeButton.isHidden = true
        }
    }
    
    // MARK: Private functions
    
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
    
    
    // MARK: Actions
    @IBAction func signButtonTapped(_ sender: Any) {
        let signInViewController: SignInViewController = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    @IBAction func toLibrariesButtonTapped(_ sender: Any) {
        let vc: LibrariesViewController = self.storyboard?.instantiateViewController(withIdentifier: "LibrariesViewController") as! LibrariesViewController
        getNamesData(completion: { arr in
            vc.bookStoreTitlesTemp = arr
            vc.bookStoreTitles = arr
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @IBAction func homeButtonTapped(_ sender: Any) {
        if appDelegate().currentUser != nil {
            let user = appDelegate().currentUser
            firestoreManager.getUsersApplications(email: user!.email, completion: { arr in
                let vc: UserProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                
                vc.email = user?.email
                vc.firstName = user?.firstName
                vc.lastName = user?.lastName
                vc.age = user?.age
                vc.username = user?.username
                vc.phoneNumber = user?.phoneNumber
                vc.address = user?.location
                vc.arr = arr
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
        } else if appDelegate().currentBookstoreOwner != nil {
            let owner = appDelegate().currentBookstoreOwner
            
            let tabBC: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
            let nav = tabBC.viewControllers?[0] as! UINavigationController
            let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
            let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
            
            let bookstoreVC = nav.topViewController as! LibraryViewController
            let applicationsVC = nav_1.topViewController as! ApplicationsListViewController
            let favouritesVC = nav_2.topViewController as! FavouritesViewController
            
            firestoreManager.getRecommendedBooks(email: owner!.email, completion: { arr in
                self.firestoreManager.configureRandomBooksOfRandomGenre(email: owner!.email, completion: { randArr in
                    self.firestoreManager.configureRecentlyAddedBooks(email: owner!.email, completion: { recentlyAddedArr in
                        self.firestoreManager.getApplications(email: owner!.email, completion: { appls in
                            favouritesVC.recommendedBooksArr = arr
                            favouritesVC.randomBooksArr = randArr
                            favouritesVC.recentlyAddedBooksArr = recentlyAddedArr
                            
                            applicationsVC.applicationsArr = appls
                            
                            bookstoreVC.phoneNumber = owner?.phoneNumber
                            bookstoreVC.address = owner?.location
                            bookstoreVC.bookstoreName = owner?.name
                            bookstoreVC.preference = owner?.preference
                            bookstoreVC.email = owner?.email
                            bookstoreVC.bookstoreOwnersName = owner?.ownersName
                            bookstoreVC.additionalInfoText = owner?.additionalInfo
                            
                            UIApplication.shared.keyWindow?.rootViewController = tabBC
                        })
                    })
                    
                })
            })
            
        }
    }
}



