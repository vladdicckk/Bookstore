//
//  SetLibraryOwnerName.swift
//  OnlineLibrary
//
//  Created by iosdev on 19.01.2023.
//

import UIKit
import FirebaseFirestore

protocol NameSendingDelegateProtocol {
    func sendNameDataToFirstViewController(name: String)
}

class SetLibraryOwnerName: UIViewController{
    // MARK: Outlets
    @IBOutlet weak var setNameTextField: UITextField!
    
    // MARK: Properties
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var delegate: NameSendingDelegateProtocol? = nil
    var bookstoreOwnersEmail: String?
    var setName: String?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewProperties()
        setNameTextField.becomeFirstResponder()
    }
    
    // MARK: Private and public functions
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
    
    override func updateViewConstraints() {
        self.view.frame.size.height = self.setNameTextField.frame.size.height * 4
        self.view.frame.origin.y = 300
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let bookstoreOwnersEmail = bookstoreOwnersEmail else { return }
        if self.delegate != nil {
            let name: String  = setNameTextField.text ?? ""
            
            firestoreManager.editLibraryOwnersNameFirestore(name: name, email: bookstoreOwnersEmail)
            self.delegate?.sendNameDataToFirstViewController(name: name)
            dismiss(animated: true, completion: nil)
        }
    }
}
