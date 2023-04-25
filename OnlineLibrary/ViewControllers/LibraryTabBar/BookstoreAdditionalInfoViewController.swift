//
//  BookstoreAdditionalInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 12.04.2023.
//

import UIKit
import FirebaseFirestore

protocol BookstoreAdditionalInfo {
    func setBookstoreAdditionalInfo(additionalInfo text: String)
}

class BookstoreAdditionalInfoViewController: UIViewController {
    @IBOutlet weak var saveAdditionalInfoDataButton: UIButton!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    var additionalInfoText: String?
    let db = Firestore.firestore()
    var delegate: BookstoreAdditionalInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        if additionalInfoText == nil || additionalInfoText == "" {
            additionalInfoTextView.text = "Owner have not share any info about his library yet."
        }
        accessSettings()
        setText()
        textViewProperties()
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    private func setText() {
        additionalInfoTextView.text = additionalInfoText
    }
    
    private func accessSettings() {
        if appDelegate().currentReviewingOwnersProfile != nil && appDelegate().currentReviewingOwnersProfile != appDelegate().currentBookstoreOwner {
            saveAdditionalInfoDataButton.isHidden = true
            additionalInfoTextView.isEditable = false
        } else {
            saveAdditionalInfoDataButton.isHidden = false
            additionalInfoTextView.isEditable = true
        }
    }
    
    override func updateViewConstraints() {
        view.frame.size.height = additionalInfoTextView.height + saveAdditionalInfoDataButton.height*4
        view.frame.origin.y = view.height/2
        view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    private func textViewProperties() {
        additionalInfoTextView.backgroundColor = .clear
        
        let backgroundTextViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 20
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        additionalInfoTextView.superview?.addSubview(backgroundTextViewBlur)
        additionalInfoTextView.superview?.sendSubviewToBack(backgroundTextViewBlur)
        
        backgroundTextViewBlur.translatesAutoresizingMaskIntoConstraints  = false
        NSLayoutConstraint.activate([
            backgroundTextViewBlur.topAnchor.constraint(equalTo: additionalInfoTextView.topAnchor),
            backgroundTextViewBlur.leadingAnchor.constraint(equalTo: additionalInfoTextView.leadingAnchor, constant: -15),
            backgroundTextViewBlur.trailingAnchor.constraint(equalTo: additionalInfoTextView.trailingAnchor, constant: 15),
            backgroundTextViewBlur.bottomAnchor.constraint(equalTo: additionalInfoTextView.bottomAnchor, constant: 20)
        ])
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if delegate != nil {
            guard let bookstoreEmail = appDelegate().currentBookstoreOwner?.email else { return }
            delegate?.setBookstoreAdditionalInfo(additionalInfo: additionalInfoTextView.text)
            db.collection("Owners").document(bookstoreEmail).setData(["additionalInfo" : "\(additionalInfoTextView.text ?? "")"], merge: true)
            dismiss(animated: true)
        }
    }
}
