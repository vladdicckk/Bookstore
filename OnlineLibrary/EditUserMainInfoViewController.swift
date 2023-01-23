//
//  EditUserMainInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 23.01.2023.
//

import UIKit

protocol MainInfoSendingDelegateProtocol {
    func sendMainInfoDataToFirstViewController(email: String, phoneNumber: String, location: String, username: String)
}

class EditUserMainInfoViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var editPhoneNumberTextField: UITextField!
    @IBOutlet weak var editEmailTextField: UITextField!
    @IBOutlet weak var editAddressTextField: UITextField!
    @IBOutlet weak var editUsernameTextField: UITextField!
    
    // MARK: Parameters
    var oldPhoneNumber: String?
    var oldEmail: String?
    var oldAddress: String?
    var oldUsername: String?
    var delegate: MainInfoSendingDelegateProtocol? = nil
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        editPhoneNumberTextField.text = oldPhoneNumber
        editEmailTextField.text = oldEmail
        editAddressTextField.text = oldAddress
        editUsernameTextField.text = oldUsername
        mainViewProperties()
    }
    
    // MARK: Private functions
    private func mainViewProperties(){
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
        self.view.frame.size.height = self.mainView.frame.size.height
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.delegate != nil {
            
            let email: String  = editEmailTextField.text ?? ""
            let phoneNumber: String  = editPhoneNumberTextField.text ?? ""
            let location: String  = editAddressTextField.text ?? ""
            let username: String  = editUsernameTextField.text ?? ""
            
            self.delegate?.sendMainInfoDataToFirstViewController(email: email, phoneNumber: phoneNumber, location: location, username: username)
            dismiss(animated: true, completion: nil)
        }
    }
}
