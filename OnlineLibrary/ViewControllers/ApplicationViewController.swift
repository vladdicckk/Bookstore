//
//  ApplicationViewController.swift
//  Pods
//
//  Created by iosdev on 14.02.2023.
//

import UIKit
import FirebaseFirestore

class ApplicationViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var bookstoreNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var typeOfTrading: UILabel!
    @IBOutlet weak var bookInfoLabel: UILabel!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var switchStatus: UISwitch!
    @IBOutlet weak var failureLabel: UILabel!
    
    // MARK: Parameters
    var application: ApplicationMainInfo?
    var db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var isTextViewMustBeHidden: Bool?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        if appDelegate().currentReviewingUsersProfile != nil {
            successLabel.isHidden = true
            failureLabel.isHidden = true
            switchStatus.isHidden = true
        }
        
        if isTextViewMustBeHidden ?? false {
            NSLayoutConstraint.activate([
                mainView.heightAnchor.constraint(equalToConstant: mainInfoView.height + 50),
                view.heightAnchor.constraint(equalToConstant: mainInfoView.height + 50)
            ])
            additionalInfoTextView.isHidden = true
        }
        
        additionalInfoTextView.isEditable = false
        configureApplicationInfo()
        setupMainView()
        setupTextView()
        setupMainInfoView()
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissOnPan))
        mainInfoView.addGestureRecognizer(pan)
    }
    
    @objc func dismissOnPan() {
        dismiss(animated: true)
    }
    
    // MARK: Private functions
    private func configureApplicationInfo() {
        additionalInfoTextView.text = "\(application?.additionalInfo ?? "") \nUserInfo: \(application?.userInfo ?? "")"
        bookstoreNameLabel.text = application?.bookstoreName
        dateLabel.text = "Date: \(application?.date ?? "")"
        
        guard let status = application?.status else { return }
        
        if status {
            switchStatus.isOn = true
            statusLabel.text = "Success"
        } else {
            switchStatus.isOn = false
            statusLabel.text = "Failure"
        }
        
        typeOfTrading.text = application?.type
        bookInfoLabel.text = "Book title: \(application?.book.title ?? "") \nAuthor: \(application?.book.author ?? "")"
    }
    
    private func setupMainView() {
        mainView.layer.cornerRadius = 16
        mainView.backgroundColor = .clear
        createLightBlurEffect(alpha: 1, view: mainView)
    }
    
    private func setupMainInfoView() {
        mainInfoView.layer.cornerRadius = 16
        mainInfoView.layer.borderColor = UIColor.systemBrown.cgColor
        mainInfoView.layer.borderWidth = 2.0
        mainInfoView.backgroundColor = .clear
        createLightBlurEffect(alpha: 0.75, view: mainInfoView)
    }
    
    private func setupTextView() {
        additionalInfoTextView.layer.cornerRadius = 16
        additionalInfoTextView.backgroundColor = .clear
        additionalInfoTextView.layer.borderColor = UIColor.brown.cgColor
        additionalInfoTextView.layer.borderWidth = 2.0
        createLightBlurEffect(alpha: 0.75, view: additionalInfoTextView)
    }
    
    private func setSwitchedStatus() {
        guard let title = application?.book.title else { return }
        guard let email = appDelegate().currentBookstoreOwner?.email else { return }
        
        firestoreManager.setStatusInDB(email: email, title: title, status: self.switchStatus.isOn, application: self.application!)
    }
    
    private func createLightBlurEffect(alpha: Double, view: UIView) {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = alpha
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 18
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
    
    @IBAction func didSwitchStatus(_ sender: Any) {
        setSwitchedStatus()
        
        if switchStatus.isOn {
            statusLabel.text = "Success"
        } else {
            statusLabel.text = "Failure"
        }
    }
}
