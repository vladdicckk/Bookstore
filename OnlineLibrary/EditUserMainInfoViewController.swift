//
//  EditUserMainInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 23.01.2023.
//

import UIKit
import FirebaseFirestore

protocol MainInfoSendingDelegateProtocol {
    func sendMainInfoDataToFirstViewController(phoneNumber: String, location: String, username: String)
}

class EditUserMainInfoViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var editPhoneNumberTextField: UITextField!
    @IBOutlet weak var editAddressTextField: UITextField!
    @IBOutlet weak var editUsernameTextField: UITextField!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    var userEmail: String?
    var oldPhoneNumber: String?
    var oldAddress: String?
    var oldUsername: String?
    var delegate: MainInfoSendingDelegateProtocol? = nil
    let firestoreManager = FirestoreManager()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        editPhoneNumberTextField.text = oldPhoneNumber
        editAddressTextField.text = oldAddress
        editUsernameTextField.text = oldUsername
        mainViewProperties()
    }
    
    // MARK: Private functions
    private func mainViewProperties() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        view.addSubview(backgroundBlur)
        view.sendSubviewToBack(backgroundBlur)
        
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            backgroundBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    private func getNamesData(completion: @escaping ([String]) -> ()) {
        db.collection("Users").getDocuments() { (querySnapshot, err) in
            guard let querySnapshot = querySnapshot else { return }
            var arr: [String] = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot.documents {
                    arr.append("\(document.get("username") ?? "")")
                }
                completion(arr)
            }
        }
    }
    
    private func checkForUsernameExisting(username: String, email: String, _ completion: @escaping (_ usernameExists: Bool) -> Void) {
        let users = db.collection("Users")
        
        users.document(email).getDocument { query, err in
            if query!.exists {
                self.getNamesData(completion: { arr in
                    for name in arr {
                        if name == username {
                            completion(true)
                        }
                    }
                    completion(false)
                })
            } else {
                completion(false)
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        
        present(alert, animated: true, completion: nil)
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = self.mainView.frame.size.height
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let userEmail = userEmail else { return }
        if self.delegate != nil {
            let phoneNumber: String  = editPhoneNumberTextField.text ?? ""
            let location: String  = editAddressTextField.text ?? ""
            let username: String  = editUsernameTextField.text ?? ""
            checkForUsernameExisting(username: username, email: userEmail, { exists in
                if username != self.oldUsername {
                    if !exists {
                        self.firestoreManager.editUserData(phoneNumber: phoneNumber, address: location, email: userEmail, username: username)
                        
                        self.delegate?.sendMainInfoDataToFirstViewController(phoneNumber: phoneNumber, location: location, username: username)
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        self.showAlert(message: "Username already exists")
                    }
                } else {
                    self.firestoreManager.editUserData(phoneNumber: phoneNumber, address: location, email: userEmail, username: username)
                    
                    self.delegate?.sendMainInfoDataToFirstViewController(phoneNumber: phoneNumber, location: location, username: username)
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
    }
}
