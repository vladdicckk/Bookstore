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
        }
    }
    
    // MARK: Private and public functions
    private func setUsersData(name: String, surname: String, password: String, age: Int, email: String, address: String, phoneNumber: String, username: String) {
        let users = db.collection("Users")
        
        let user = User(firstName: name, lastName: surname, age: age, password: password, email: email, username: username, phoneNumber: phoneNumber, location: address)
        do {
            try users.addDocument(from: user)
                //.document("Username : \(username)").setData(from: user)
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
    
    private func validation(username: String, email: String, phoneNumber: String) -> Bool{
        //validation.isEmailUnique(email: email)
        
        if !validation.isEmail(enteredEmail: email){
            showAlert(message: "Please, enter correct email")
            return false
        } else if !validation.isEmailUnique(email: email) {
            showAlert(message: "Email must be unique")
            return false
        } else if !validation.isUsernameUnique(username: username) {
            showAlert(message: "Username must be unique")
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
                //if validation(username: username, email: email, phoneNumber: phoneNumber) {
                    setUsersData(name: name, surname: surname, password: password, age: age, email: email, address: address, phoneNumber: phoneNumber, username: username)
                    
                    let userProfileVC: UserProfileViewController = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                    self.navigationController?.pushViewController(userProfileVC, animated: true)
                //}
            } else {
                showAlert(message: "You need to confirm your password")
            }
        } else {
            showAlert(message: "All fields must be filled")
        }
    }
}
