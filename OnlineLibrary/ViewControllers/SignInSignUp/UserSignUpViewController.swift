//
//  UserSignUpViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseAuth

class UserSignUpViewController: UIViewController, UITextFieldDelegate {
    // MARK: Outlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthDatePicker: UIDatePicker!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    
    // MARK: Parameters
    let firestoreManager = FirestoreManager()
    let validation: Validation = Validation()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        phoneNumberTextField.delegate = self
        super.viewDidLoad()
        lowerView.setCorner(radius: 16)
        upperView.setCorner(radius: 16)
    }
    
    // MARK: Private and public functions
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return false }
        
        if textField == phoneNumberTextField {
            // TODO: CODE_REVIEW. random strings
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            if (newString.first == "0") {
                textField.text = FormatStrings.formatForPhoneNumber(with: "XXX-XXX-XX-XX", phone: newString)
            } else {
                textField.text = FormatStrings.formatForPhoneNumber(with: "+XXX-XX-XXX-XX-XX", phone: newString)
            }
        } else {
            return true
        }
        return false
    }
    
    private func signUp(email: String, password: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password)
    }
    
    private func validation(email: String, phoneNumber: String) -> Bool {
        if !validation.isEmail(enteredEmail: email) {
            showAlert(message: "Please, enter correct email")
            return false
        }
        return true
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func makeAgeFromDatePicker() -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: birthDatePicker.date)
        let age = currentYear - (Int(yearString) ?? 0)
        return age
    }
    
    // MARK: Actions
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let age = makeAgeFromDatePicker()
        guard let name = firstNameTextField.text, let surname = lastNameTextField.text, let password = passwordTextField.text, let email = emailTextField.text, let address = addressTextField.text, let username = usernameTextField.text, let phoneNumber = phoneNumberTextField.text else {
            return
        }
        
        if name != "" && surname != "" && password != "" && email != "" && address != "" && phoneNumber != "" && username != "" {
            if password == confirmPasswordTextField.text {
                if validation(email: email, phoneNumber: phoneNumber) {
                    firestoreManager.checkForUsernameExisting(username: username, { [weak self]  usernameExists in
                        if usernameExists {
                            self?.showAlert(message: "Username already exists")
                        } else {
                            self?.firestoreManager.checkForUserExisting(email: email, { exists in
                                if exists {
                                    self?.showAlert(message: "Email already exists")
                                } else {
                                    FirebaseManager.shared.insertUser(with:
                                                                    ChatAppUser(name: name, surname: surname, email: email), completion: { success in
                                    let user = User(firstName: name, lastName: surname, age: age, password: password, email: email, username: username, phoneNumber: phoneNumber, location: address)
                                    self?.firestoreManager.addUser(user: user)
                                    
                                        
                                    
                                    self?.appDelegate().currentUser = user
                                    let userProfileVC: UserProfileViewController = self?.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                                    
                                    userProfileVC.firstName = name
                                    userProfileVC.lastName = surname
                                    userProfileVC.age = age
                                    userProfileVC.email = email
                                    userProfileVC.username = username
                                    userProfileVC.phoneNumber = phoneNumber
                                    userProfileVC.address = address
                                    
                                    self?.signUp(email: email, password: password)
                                    self?.dismiss(animated: false)
                                    })
                                }
                            })
                        }
                    })
                }
            } else {
                showAlert(message: "You need to confirm your password")
            }
        } else {
            showAlert(message: "All fields must be filled")
        }
    }
}
