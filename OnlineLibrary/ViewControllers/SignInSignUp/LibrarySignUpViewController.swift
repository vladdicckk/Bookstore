//
//  LibrarySignUpViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LibrarySignUpViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var bookstoreNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var tradingPreferenceTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var showPickerButton: UIButton!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    let validation: Validation = Validation()
    var rolesPicker = UIPickerView()
    var toolBar = UIToolbar()
    var preferences: [String] = ["Trading","Exchanging","Both"]
    var selectedIndex: Int = 0
    
    
    // MARK: Lifecycle funcitons
    override func viewDidLoad() {
        super.viewDidLoad()
        tradingPreferenceTextField.isEnabled = false
        upperView.setCorner(radius: 16)
        lowerView.setCorner(radius: 16)
        tradingPreferenceTextField.text = "Trading"
        phoneNumberTextField.delegate = self
    }
    
    // MARK: Private functions
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
    
    // MARK: Actions
    @IBAction func didTapPickPreferences(_ sender: UIButton) {
        rolesPicker = UIPickerView.init()
        rolesPicker.delegate = self
        rolesPicker.dataSource = self
        rolesPicker.backgroundColor = UIColor.white
        rolesPicker.autoresizingMask = .flexibleWidth
        rolesPicker.contentMode = .center
        rolesPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        view.addSubview(rolesPicker)
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        view.addSubview(toolBar)
        rolesPicker.selectRow(selectedIndex, inComponent: 0, animated: true)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        rolesPicker.removeFromSuperview()
    }
    
    // TODO: Check user internet connection, if bad or none - show alert
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let bookstoreName = bookstoreNameTextField.text, let phoneNumber = phoneNumberTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text, let address = addressTextField.text, let preference = tradingPreferenceTextField.text else { return }
        
        if bookstoreName != "" && preference != "" && password != "" && email != "" && address != "" && phoneNumber != "" {
            if password == confirmPassword {
                if validation(email: email, phoneNumber: phoneNumber) {
                    firestoreManager.checkForBookstoreNameExisting(bookstoreName: bookstoreName, email: email, {[weak self]  nameExists in
                        if nameExists {
                            self?.showAlert(message: "Bookstore name already exists")
                        } else {
                            self?.firestoreManager.checkForBookstoreExisting(email: email, { exists in
                                if exists {
                                    self?.showAlert(message: "Email already exists")
                                } else {
                                    FirebaseManager.shared.insertUser(with:
                                                                        ChatAppUser(name: bookstoreName, surname: "", email: email), completion: { success in
                                        let emptyBookInfo: BookInfo = BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")
                                        let bookstore = Bookstore(name: bookstoreName,ownersName: "Set your name", password: password, preference: preference, phoneNumber: phoneNumber, email: email, location: address, additionalInfo: "", books: [emptyBookInfo])
                                        self?.firestoreManager.addBookstore(bookstore: bookstore)
                                        
                                        let tabBC: UITabBarController = self?.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
                                        let nav = tabBC.viewControllers?[0] as! UINavigationController
                                        let bookstoreProfileVC = nav.topViewController as! LibraryViewController
                                        bookstoreProfileVC.bookstoreName = bookstoreName
                                        bookstoreProfileVC.email = email
                                        bookstoreProfileVC.preference = preference
                                        bookstoreProfileVC.phoneNumber = phoneNumber
                                        bookstoreProfileVC.address = address
                                        
                                        self?.appDelegate().currentBookstoreOwner = bookstore
                                        
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
    
    // MARK: UIPickerViewDelegate and UIPickerViewDataSource functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        preferences.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        preferences[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        tradingPreferenceTextField.text = preferences[row]
    }
}
