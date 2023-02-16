//
//  EditLibraryInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit
import FirebaseFirestore

protocol MainSendingDelegateProtocol {
    func sendMainDataToFirstViewController(bookstoreName: String, phoneNumber: String, location: String, preferences: String)
}

class EditLibraryInfoViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var editBookstoreNameTextField: UITextField!
    @IBOutlet weak var editOwnerPhoneNumberTextField: UITextField!
    @IBOutlet weak var editLibraryLocationTextField: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var editExchangeOrTradingPreferences: UITextField!
    
    // MARK: Properties
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var bookStoreOwnersEmail: String?
    var oldLibraryLocation: String?
    var oldOwnerPhoneNumber: String?
    var oldBookstoreTitle: String?
    var oldOwnerPreferences: String?
    var delegate: MainSendingDelegateProtocol? = nil
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        editOwnerPhoneNumberTextField.text = oldOwnerPhoneNumber
        editLibraryLocationTextField.text = oldLibraryLocation
        editExchangeOrTradingPreferences.text = oldOwnerPreferences
        mainViewProperties()
    }
    
    // MARK: Private and public functions
    func mainViewProperties() {
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
        mainView.addSubview(backgroundBlur)
        mainView.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            backgroundBlur.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            backgroundBlur.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            backgroundBlur.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0)
        ])
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = self.mainView.frame.size.height
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let bookStoreOwnersEmail = bookStoreOwnersEmail else { return }
        if self.delegate != nil {
            let bookstoreName: String  = oldBookstoreTitle ?? ""
            let phoneNumber: String  = editOwnerPhoneNumberTextField.text ?? ""
            let location: String  = editLibraryLocationTextField.text ?? ""
            let preferences: String  = editExchangeOrTradingPreferences.text ?? ""
            
            firestoreManager.editBookstoreAndOwnersDataFirestore(location: location, email: bookStoreOwnersEmail, phoneNumber: phoneNumber, exchangePreference: preferences)
            self.delegate?.sendMainDataToFirstViewController(bookstoreName: bookstoreName, phoneNumber: phoneNumber, location: location, preferences: preferences)
            dismiss(animated: true, completion: nil)
        }
    }
}
