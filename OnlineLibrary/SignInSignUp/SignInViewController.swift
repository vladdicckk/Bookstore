//
//  SignInViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseFirestore

class SignInViewController: UIViewController, UITextFieldDelegate {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    
    // MARK: Lifecycle functions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.isEnabled = false
        self.navigationController?.isNavigationBarHidden = false
        loginTextField.attributedPlaceholder = NSAttributedString(string: "Your bookstore name, profile username or e-mail", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 8.0)
        ])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 10.0)
        ])
        loginTextField.text = "myUsername"
        //"email@email.coms""myUsername"
        passwordTextField.text = "tes"
        
        upperView.setCorner(radius: 16)
        lowerView.setCorner(radius: 16)
    }
    
    // MARK: Private and public functions
    
    private func showSignUpErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func signInButtonTapped(_ sender: Any) {
        
        firestoreManager.checkForBookstoreExisting(email: loginTextField.text ?? "", { exists in
            if exists {
                self.firestoreManager.checkForValidPasswordForEmailLogin(email: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "", { isValid, bookstoreData in
                    if isValid {
                        self.appDelegate().currentBookstoreOwner = bookstoreData
                        self.appDelegate().currentUser = nil
                        let tabBC: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
                        let nav = tabBC.viewControllers?[0] as! UINavigationController
                        let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
                        let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
                        
                        let bookstoreVC = nav.topViewController as! LibraryViewController
                        let applicationsVC = nav_1.topViewController as! ApplicationsListViewController
                        let favouritesVC = nav_2.topViewController as! FavouritesViewController
                        
                        self.firestoreManager.getRecommendedBooks(email: bookstoreData.email, completion: { arr in
                            self.firestoreManager.configureRandomBooksOfRandomGenre(email: bookstoreData.email, completion: { randArr in
                                self.firestoreManager.configureRecentlyAddedBooks(email: bookstoreData.email, completion: { recentlyAddedArr in
                                    self.firestoreManager.getApplications(email: bookstoreData.email, completion: { appls in
                                        favouritesVC.recommendedBooksArr = arr
                                        favouritesVC.randomBooksArr = randArr
                                        favouritesVC.recentlyAddedBooksArr = recentlyAddedArr
                                        
                                        applicationsVC.applicationsArr = appls
                                        
                                        bookstoreVC.phoneNumber = bookstoreData.phoneNumber
                                        bookstoreVC.address = bookstoreData.location
                                        bookstoreVC.bookstoreName = bookstoreData.name
                                        bookstoreVC.preference = bookstoreData.preference
                                        bookstoreVC.email = bookstoreData.email
                                        bookstoreVC.bookstoreOwnersName = bookstoreData.ownersName
                                        bookstoreVC.additionalInfoText = bookstoreData.additionalInfo
                                        
                                        UIApplication.shared.keyWindow?.rootViewController = tabBC
                                    })
                                })
                            })
                        })
                    } else {
                        self.showSignUpErrorAlert(message: "Incorrect password")
                    }
                })
            } else {
                self.firestoreManager.checkForBookstoreNameExisting(bookstoreName: self.loginTextField.text ?? "", { nameExists in
                    if nameExists {
                        self.firestoreManager.checkForValidPasswordForNameLogin(bookstoreName: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "", { isPasswordValid, bookstoreData_2 in
                            if isPasswordValid {
                                self.appDelegate().currentBookstoreOwner = bookstoreData_2
                                self.appDelegate().currentUser = nil
                                let tabBC: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
                                let nav = tabBC.viewControllers?[0] as! UINavigationController
                                let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
                                let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
                                
                                let bookstoreVC_2 = nav.topViewController as! LibraryViewController
                                let applicationsVC_2 = nav_1.topViewController as! ApplicationsListViewController
                                let favouritesVC_2 = nav_2.topViewController as! FavouritesViewController
                                
                                self.firestoreManager.getRecommendedBooks(email: bookstoreData_2.email, completion: { arr in
                                    self.firestoreManager.configureRandomBooksOfRandomGenre(email: bookstoreData_2.email, completion: { randArr in
                                        self.firestoreManager.configureRecentlyAddedBooks(email: bookstoreData_2.email, completion: { recentlyAddedArr in
                                            self.firestoreManager.getApplications(email: bookstoreData_2.email, completion: { appls in
                                                favouritesVC_2.recommendedBooksArr = arr
                                                favouritesVC_2.randomBooksArr = randArr
                                                favouritesVC_2.recentlyAddedBooksArr = recentlyAddedArr
                                                
                                                applicationsVC_2.applicationsArr = appls
                                                
                                                bookstoreVC_2.phoneNumber = bookstoreData_2.phoneNumber
                                                bookstoreVC_2.address = bookstoreData_2.location
                                                bookstoreVC_2.bookstoreName = bookstoreData_2.name
                                                bookstoreVC_2.preference = bookstoreData_2.preference
                                                bookstoreVC_2.email = bookstoreData_2.email
                                                bookstoreVC_2.bookstoreOwnersName = bookstoreData_2.ownersName
                                                bookstoreVC_2.additionalInfoText = bookstoreData_2.additionalInfo
                                                
                                                UIApplication.shared.keyWindow?.rootViewController = tabBC
                                            })
                                        })
                                        
                                    })
                                })
                            } else {
                                self.showSignUpErrorAlert(message: "Incorrect password")
                            }
                        })
                    } else {
                        self.firestoreManager.checkForUserExisting(email: self.loginTextField.text ?? "", { userExists in
                            if userExists {
                                self.firestoreManager.checkForValidPasswordForUserEmailLogin(email: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "", { isUserPasswordValid, userData in
                                    if isUserPasswordValid {
                                        self.firestoreManager.getUsersApplications(email: userData.email, completion: { appls in
                                            self.appDelegate().currentUser = userData
                                            let userVC: UserProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                                            userVC.arr = appls
                                            userVC.firstName = userData.firstName
                                            userVC.lastName = userData.lastName
                                            userVC.age = userData.age
                                            userVC.email = userData.email
                                            userVC.username = userData.username
                                            userVC.address = userData.location
                                            userVC.phoneNumber = userData.phoneNumber
                                            
                                            self.navigationController?.pushViewController(userVC, animated: false)
                                        })
                                    } else {
                                        self.showSignUpErrorAlert(message: "Incorrect password")
                                    }
                                })
                            } else {
                                self.firestoreManager.checkForUsernameExisting(username: self.loginTextField.text ?? "", { usernameExists in
                                    if usernameExists {
                                        self.firestoreManager.checkForValidPasswordForUsernameLogin(username: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "", { isUserPasswordValid_2, userData_2 in
                                            if isUserPasswordValid_2 {
                                                self.firestoreManager.getUsersApplications(email: userData_2.email, completion: { appls in
                                                    self.appDelegate().currentUser = userData_2
                                                    let userVC: UserProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                                                    userVC.arr = appls
                                                    userVC.firstName = userData_2.firstName
                                                    userVC.lastName = userData_2.lastName
                                                    userVC.age = userData_2.age
                                                    userVC.email = userData_2.email
                                                    userVC.username = userData_2.username
                                                    userVC.address = userData_2.location
                                                    userVC.phoneNumber = userData_2.phoneNumber
                                                    self.navigationController?.pushViewController(userVC, animated: false)
                                                })
                                            } else {
                                                self.showSignUpErrorAlert(message: "Incorrect password")
                                            }
                                        })
                                    } else {
                                        self.showSignUpErrorAlert(message: "Username, bookstore name or email doesn`t exist")
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // TODO: here we can check status of text fields and enable sign-in button if we can
        if loginTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false {
            signInButton.isEnabled = true
        }
        return true
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
