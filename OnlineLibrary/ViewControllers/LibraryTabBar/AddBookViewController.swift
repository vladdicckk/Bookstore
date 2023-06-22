//
//  AddBookViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 17.01.2023.
//

import UIKit
import FirebaseFirestore

class AddBookViewController: UIViewController, AdditionalInfoProtocol {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var authorTextField: UITextField!
    @IBOutlet weak var publishYearTextField: UITextField!
    @IBOutlet weak var genreTextField: UITextField!
    @IBOutlet weak var pagesCountTextField: UITextField!
    @IBOutlet weak var languageTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var additionalInfoButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var additionalInfo: String?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        upperView.layer.cornerRadius = 16
        lowerView.layer.cornerRadius = 16
        
        titleTextField.text = "TestTitle"
        authorTextField.text = "TestAuthor"
        publishYearTextField.text = "1951"
        genreTextField.text = "TestGenre"
        pagesCountTextField.text = "500"
        languageTextField.text = "TestLanguage"
        priceTextField.text = "2.31"
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(pan)
    }
    
    // MARK: Public and private functions
    func getAdditionalInfo(additionalInfoText: String) {
        additionalInfo = additionalInfoText
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Actions
    @IBAction func createButtonTapped(_ sender: Any) {
        let email = self.appDelegate().currentBookstoreOwner?.email
        if titleTextField.text != "" && authorTextField.text != "" && publishYearTextField.text != "" && genreTextField.text != "" && pagesCountTextField.text != "" && languageTextField.text != "" && priceTextField.text != "" {
            firestoreManager.checkBookTitleForExisting(title: "\(titleTextField.text ?? "")", email: email ?? "", completion: { titleExists in
                if titleExists {
                    self.firestoreManager.checkBookAuthorForExisting(title: "\(self.titleTextField.text ?? "")", email: email ?? "", author: self.authorTextField.text ?? "", completion: { authorExists in
                        if authorExists {
                            self.showAlert(message: "This book already exists in your bookstore")
                        } else {
                            self.firestoreManager.addBook(email: email ?? "", title: self.titleTextField.text ?? "" , author: self.authorTextField.text ?? "", publishYear: Int(self.publishYearTextField.text ?? "") ?? 0, genre: self.genreTextField.text ?? "", pagesCount: Int(self.pagesCountTextField.text ?? "") ?? 0, language: self.languageTextField.text ?? "", price: Double(self.priceTextField.text ?? "") ?? 0.0, additionalInfo: self.additionalInfo ?? "")
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                } else {
                    self.firestoreManager.addBook(email: email ?? "", title: self.titleTextField.text ?? "" , author: self.authorTextField.text ?? "", publishYear: Int(self.publishYearTextField.text ?? "") ?? 0, genre: self.genreTextField.text ?? "", pagesCount: Int(self.pagesCountTextField.text ?? "") ?? 0, language: self.languageTextField.text ?? "", price: Double(self.priceTextField.text ?? "") ?? 0.0, additionalInfo: self.additionalInfo ?? "")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            })

        } else {
            showAlert(message: "All fields must be filled")
        }
    }
    
    @IBAction func additionalInfoButtonTapped(_ sender: Any) {
        let vc: AddBookAdditionalInfoViewController = storyboard?.instantiateViewController(withIdentifier: "AddBookAdditionalInfoViewController") as! AddBookAdditionalInfoViewController
        vc.delegate = self
        present(vc, animated: true)
    }
}

