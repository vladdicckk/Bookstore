//
//  AddBookAdditionalInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 19.01.2023.
//

import UIKit
import FirebaseFirestore


protocol AdditionalInfoProtocol {
    func getAdditionalInfo(additionalInfoText: String)
}

class AddBookAdditionalInfoViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    var additionalInfoText: String?
    var delegate: AdditionalInfoProtocol?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalInfoTextView.text = additionalInfoText
        additionalInfoTextViewSettings()
    }
    
    // MARK: Public and private functions
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func additionalInfoTextViewSettings() {
        let backgroundTextViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.8
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        additionalInfoTextView.superview?.addSubview(backgroundTextViewBlur)
        additionalInfoTextView.superview?.sendSubviewToBack(backgroundTextViewBlur)
        
        backgroundTextViewBlur.translatesAutoresizingMaskIntoConstraints  = false
        NSLayoutConstraint.activate([
            backgroundTextViewBlur.topAnchor.constraint(equalTo: additionalInfoTextView.topAnchor, constant: -50),
            backgroundTextViewBlur.leadingAnchor.constraint(equalTo: additionalInfoTextView.leadingAnchor, constant: 0),
            backgroundTextViewBlur.trailingAnchor.constraint(equalTo: additionalInfoTextView.trailingAnchor, constant: 0),
            backgroundTextViewBlur.bottomAnchor.constraint(equalTo: additionalInfoTextView.bottomAnchor, constant: 0)
        ])
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - additionalInfoTextView.bounds.height - 50
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 15.0)
        super.updateViewConstraints()
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if additionalInfoTextView.text != "" && additionalInfoTextView.text.count > 30 {
            if delegate != nil {
                self.delegate?.getAdditionalInfo(additionalInfoText: additionalInfoTextView.text)
                dismiss(animated: true)
            }
        } else if additionalInfoTextView.text == "" {
            showAlert(message: "Additional info text can`t be empty")
        } else if additionalInfoTextView.text.count < 30 {
            showAlert(message: "Additional info text must be longer")
        }
    }
}
