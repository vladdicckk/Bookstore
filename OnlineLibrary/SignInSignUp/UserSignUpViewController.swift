//
//  UserSignUpViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore



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
    let db = Firestore.firestore()
    var ref: DocumentReference!
    var isExists = true
    let validation: Validation = Validation()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        lowerView.setCorner(radius: 16)
        upperView.setCorner(radius: 16)
        DispatchQueue.main.async {
            self.firstNameTextField.text = "test"
            self.lastNameTextField.text = "test"
            self.passwordTextField.text = "test"
            self.confirmPasswordTextField.text = "test"
            self.addressTextField.text = "test"
            self.phoneNumberTextField.text = "+380000000000"
            self.emailTextField.text = "test@gmail.com"
        }
    }
    
    // MARK: Private and public functions
    
    
    private func checkForUserExistingAndAddingUserData(email: String, _ completion: @escaping (_ exists: Bool) -> Void) {
        let users = db.collection("Users")
        
        users.document(email).getDocument { query, err in
            if query!.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func addUser(user: User) {
        let users = db.collection("Users")
        do {
            try users.document(user.email).setData(from: user)
        } catch let error {
            print ("Error: \(error)")
        }
    }
    
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
    
    //    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    //        if textField == phoneNumberTextField {
    //            textField.resignFirstResponder()
    //        }
    //        return true
    //    }
    
    private func validation(email: String, phoneNumber: String) -> Bool {
        if !validation.isEmail(enteredEmail: email){
            showAlert(message: "Please, enter correct email")
            return false
        } else if !validation.isPhoneNumber(phone: phoneNumber) {
            showAlert(message: "Please, enter correct phone number")
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
            if password == confirmPasswordTextField.text && password != "" {
                if validation(email: email, phoneNumber: phoneNumber) {
                    self.checkForUserExistingAndAddingUserData(email: email, { exists in
                        if exists {
                            self.showAlert(message: "Email already exists")
                            self.isExists = true
                        } else {
                            let user = User(firstName: name, lastName: surname, age: age, password: password, email: email, username: username, phoneNumber: phoneNumber, location: address)
                            //self.addUser(user: user)
                            let userProfileVC: UserProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                            userProfileVC.firstName = name
                            userProfileVC.lastName = surname
                            userProfileVC.age = age
                            userProfileVC.email = email
                            userProfileVC.username = username
                            userProfileVC.phoneNumber = phoneNumber
                            userProfileVC.address = address
                            self.navigationController?.pushViewController(userProfileVC, animated: true)
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
