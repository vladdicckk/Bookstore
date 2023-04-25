//
//  SignInViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController, UITextFieldDelegate {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: Parameters
    let firestoreManager = FirestoreManager()
    
    // MARK: Lifecycle functions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signInButton.isEnabled = false
        navigationController?.isNavigationBarHidden = false
        loginTextField.attributedPlaceholder = NSAttributedString(string: "Your bookstore name, profile username or e-mail", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 8.0)
        ])
        
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 10.0)
        ])
        loginTextField.text = "email@email.coms"
        //"email@email.coms""myUsername"
        passwordTextField.text = "testBookstor"
        passwordTextField.delegate = self
        upperView.backgroundColor = UIColor(red: 198/255, green: 198/255, blue: 200/255, alpha: 1)
        upperView.setCorner(radius: 16)
        lowerView.setCorner(radius: 16)
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: - Private and public functions
    private func showSignInErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func singIn(email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { resSignIn, err in
            guard err == nil, resSignIn != nil else {
                print("Error sign in: \(err?.localizedDescription ?? "")")
                completion(false)
                return
            }
            completion(true)
        })
    }

    // MARK: Actions
    @IBAction func signInButtonTapped(_ sender: Any) {
        firestoreManager.checkForBookstoreExisting(email: loginTextField.text ?? "", { [weak self] exists in
            if exists {
                self?.firestoreManager.checkForValidPasswordForEmailLogin(email: self?.loginTextField.text ?? "", password: self?.passwordTextField.text ?? "", { isValid, bookstoreData in
                    if isValid {
                        guard let self = self else { return }
                        self.appDelegate().currentBookstoreOwner = bookstoreData
                        
                        self.singIn(email: bookstoreData.email, password: bookstoreData.password, completion: { success in
                            if success {
                                FirebaseManager.shared.userExists(with: bookstoreData.email, completion: { [weak self] exists in
                                    if !exists {
                                    } else {
                                        self?.appDelegate().currentEmail = bookstoreData.email
                                        guard let navVc = self?.storyboard?.instantiateViewController(withIdentifier: "navController") as? UINavigationController else { return }
                                        UIApplication.shared.keyWindow?.rootViewController = navVc
                                    }
                                })
                            } else {
                                print("Failure")
                            }
                        })
                    } else {
                        self?.showSignInErrorAlert(message: "Incorrect password")
                    }
                })
            } else {
                self?.firestoreManager.checkForBookstoreNameExisting(bookstoreName: self?.loginTextField.text ?? "", { nameExists in
                    if nameExists {
                        self?.firestoreManager.checkForValidPasswordForNameLogin(bookstoreName: self?.loginTextField.text ?? "", password: self?.passwordTextField.text ?? "", { isPasswordValid, bookstoreData_2 in
                            if isPasswordValid {
                                self?.appDelegate().currentBookstoreOwner = bookstoreData_2
                                                              
                                self?.singIn(email: bookstoreData_2.email, password: bookstoreData_2.password, completion: { success in
                                    if success {
                                        FirebaseManager.shared.userExists(with: bookstoreData_2.email, completion: { [weak self] exists in
                                            if !exists {
                                            } else {
                                                self?.appDelegate().currentEmail = bookstoreData_2.email
                                                guard let navVc = self?.storyboard?.instantiateViewController(withIdentifier: "navController") as? UINavigationController else { return }
                                                UIApplication.shared.keyWindow?.rootViewController = navVc
                                            }
                                        })
                                    } else {
                                        print("Failure")
                                    }
                                })
                            } else {
                                self?.showSignInErrorAlert(message: "Incorrect password")
                            }
                        })
                    } else {
                        self?.firestoreManager.checkForUserExisting(email: self?.loginTextField.text ?? "", { userExists in
                            if userExists == true {
                                self?.firestoreManager.checkForValidPasswordForUserEmailLogin(email: self?.loginTextField.text ?? "", password: self?.passwordTextField.text ?? "", { isUserPasswordValid, userData in
                                    if isUserPasswordValid {
                                        self?.appDelegate().currentUser = userData
                                                                             
                                        self?.singIn(email: userData.email, password: userData.password, completion: { success in
                                            if success {
                                                FirebaseManager.shared.userExists(with: userData.email, completion: { [weak self] exists in
                                                    if !exists {
                                                    } else {
                                                        self?.appDelegate().currentEmail = userData.email
                                                        guard let navVc = self?.storyboard?.instantiateViewController(withIdentifier: "navController") as? UINavigationController else { return }
                                                        UIApplication.shared.keyWindow?.rootViewController = navVc
                                                    }
                                                })
                                            } else {
                                                print("Failure")
                                            }
                                        })
                                    } else {
                                        self?.showSignInErrorAlert(message: "Incorrect password")
                                    }
                                })
                            } else if userExists == false {
                                self?.firestoreManager.checkForUsernameExisting(username: self?.loginTextField.text ?? "", { usernameExists in
                                    if usernameExists {
                                        self?.firestoreManager.checkForValidPasswordForUsernameLogin(username: self?.loginTextField.text ?? "", password: self?.passwordTextField.text ?? "", { isUserPasswordValid_2, userData_2 in
                                            if isUserPasswordValid_2 {
                                                self?.appDelegate().currentUser = userData_2
                                              
                                                self?.singIn(email: userData_2.email, password: userData_2.password, completion: { success in
                                                    if success {
                                                        FirebaseManager.shared.userExists(with: userData_2.email, completion: { [weak self] exists in
                                                            if !exists {
                                                            } else {
                                                                self?.appDelegate().currentEmail = userData_2.email
                                                                guard let navVc = self?.storyboard?.instantiateViewController(withIdentifier: "navController") as? UINavigationController else { return }
                                                                UIApplication.shared.keyWindow?.rootViewController = navVc
                                                            }
                                                        })
                                                    } else {
                                                        print("Failure")
                                                    }
                                                })
                                            } else {
                                                self?.showSignInErrorAlert(message: "Incorrect password")
                                            }
                                        })
                                    } else {
                                        self?.showSignInErrorAlert(message: "Username, bookstore name or email doesn`t exist")
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
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
//self?.firestoreManager.checkForValidPasswordForNameLogin(bookstoreName: self?.loginTextField.text ?? "", password: self?.passwordTextField.text ?? "", { isPasswordValid, bookstoreData_2 in
//    if isPasswordValid {
//        self?.appDelegate().currentBookstoreOwner = bookstoreData_2
//        self?.appDelegate().currentUser = nil
//        let tabBC: UITabBarController = self?.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
//        let nav = tabBC.viewControllers?[0] as! UINavigationController
//        let nav_1 = tabBC.viewControllers?[3] as! UINavigationController
//        let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
//
//        let bookstoreVC_2 = nav.topViewController as! LibraryViewController
//        let applicationsVC_2 = nav_1.topViewController as! ApplicationsListViewController
//        let favouritesVC_2 = nav_2.topViewController as! FavouritesViewController
//
//        self?.firestoreManager.getRecommendedBooks(email: bookstoreData_2.email, completion: { arr in
//            self?.firestoreManager.configureRandomBooksOfRandomGenre(email: bookstoreData_2.email, completion: { randArr in
//                self?.firestoreManager.configureRecentlyAddedBooks(email: bookstoreData_2.email, completion: { recentlyAddedArr in
//                    self?.firestoreManager.getApplications(email: bookstoreData_2.email, completion: { appls in
//                        favouritesVC_2.recommendedBooksArr = arr
//                        favouritesVC_2.randomBooksArr = randArr
//                        favouritesVC_2.recentlyAddedBooksArr = recentlyAddedArr
//
//                        applicationsVC_2.applicationsArr = appls
//
//                        bookstoreVC_2.phoneNumber = bookstoreData_2.phoneNumber
//                        bookstoreVC_2.address = bookstoreData_2.location
//                        bookstoreVC_2.bookstoreName = bookstoreData_2.name
//                        bookstoreVC_2.preference = bookstoreData_2.preference
//                        bookstoreVC_2.email = bookstoreData_2.email
//                        bookstoreVC_2.bookstoreOwnersName = bookstoreData_2.ownersName
//                        bookstoreVC_2.additionalInfoText = bookstoreData_2.additionalInfo
//
//                        UIApplication.shared.keyWindow?.rootViewController = tabBC
//                    })
//                })
//
//            })
//        })



//self?.firestoreManager.getUsersApplications(email: userData.email, completion: { appls in
//    self?.firestoreManager.downloadUserAvatar(email: userData.email, completion: { image in
//        DispatchQueue.main.async {
//            let userVC: UserProfileViewController = self?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
//            userVC.currentImage = image
//            userVC.arr = appls
//            userVC.firstName = userData.firstName
//            userVC.lastName = userData.lastName
//            userVC.age = userData.age
//            userVC.email = userData.email
//            userVC.username = userData.username
//            userVC.address = userData.location
//            userVC.phoneNumber = userData.phoneNumber
//
//            self?.navigationController?.pushViewController(userVC, animated: false)
//        }
//    })
//})
