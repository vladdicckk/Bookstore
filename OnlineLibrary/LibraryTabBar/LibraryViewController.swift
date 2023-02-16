//
//  LibraryViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 07.01.2023.
//

import UIKit
import FirebaseFirestore

class LibraryViewController: UIViewController, UITextViewDelegate, MainSendingDelegateProtocol, NameSendingDelegateProtocol {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet var mainLibraryView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var ownersName: UILabel!
    @IBOutlet weak var bookstoreNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var typeOfTrading: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var libraryInfoEditButton: UIButton!
    @IBOutlet weak var setOwnersName: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var saveAdditionalInfoDataButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    // MARK: Parameters
    var bookstoreName: String?
    var address: String?
    var phoneNumber: String?
    var preference: String?
    var email: String?
    var bookstoreOwnersName: String?
    var additionalInfoText: String?
    let db = Firestore.firestore()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if appDelegate().currentBookstoreOwner == nil {
            self.tabBarController?.viewControllers?.remove(at: 3)
        }
        
        bookstoreInfoConfiguration()
        mainLibraryViewProperties()
        if appDelegate().currentBookstoreOwner == nil {
            libraryInfoEditButton.isHidden = true
            setOwnersName.isHidden = true
            saveAdditionalInfoDataButton.isHidden = true
            additionalInfoTextView.isEditable = false
            if #available(iOS 16.0, *) {
                logoutButton.isHidden = true
            } else {
                logoutButton.isEnabled = false
                // Fallback on earlier versions
            }
        }
        
        if appDelegate().currentReviewingOwnersProfile != nil && appDelegate().currentBookstoreOwner != nil {
            libraryInfoEditButton.isHidden = true
            setOwnersName.isHidden = true
            saveAdditionalInfoDataButton.isHidden = true
            additionalInfoTextView.isEditable = false
            if #available(iOS 16.0, *) {
                logoutButton.isHidden = true
            } else {
                logoutButton.isEnabled = false
                // Fallback on earlier versions
            }
        }
        self.title = bookstoreName
        navigationController?.navigationBar.prefersLargeTitles = true
        upperView.isHidden = true
    }
    
    // MARK: Private and public functions
    private func bookstoreInfoConfiguration() {
        bookstoreNameLabel.text = bookstoreName
        locationLabel.text = address
        contactPhoneLabel.text = phoneNumber
        emailLabel.text = email
        typeOfTrading.text = preference
        ownersName.text = bookstoreOwnersName
        additionalInfoTextView.text = additionalInfoText
    }
    
    
    func sendNameDataToFirstViewController(name: String) {
        ownersName.text = name
    }
    
    func sendMainDataToFirstViewController(bookstoreName: String, phoneNumber: String, location: String, preferences: String) {
        bookstoreNameLabel.text = bookstoreName
        contactPhoneLabel.text = phoneNumber
        locationLabel.text = location
        typeOfTrading.text = preferences
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getMainDataSegue" {
            let editLibraryInfoVC: EditLibraryInfoViewController = segue.destination as! EditLibraryInfoViewController
            editLibraryInfoVC.bookStoreOwnersEmail = email
            editLibraryInfoVC.oldBookstoreTitle = bookstoreNameLabel.text
            editLibraryInfoVC.oldOwnerPhoneNumber = contactPhoneLabel.text
            editLibraryInfoVC.oldLibraryLocation = locationLabel.text
            editLibraryInfoVC.oldOwnerPreferences = typeOfTrading.text
            editLibraryInfoVC.delegate = self
        }
        
        if segue.identifier == "getNameData" {
            let setNameVC: SetLibraryOwnerName = segue.destination as! SetLibraryOwnerName
            setNameVC.setName = ownersName.text
            setNameVC.bookstoreOwnersEmail = email
            setNameVC.delegate = self
        }
    }
    
    private func createLightBlurEffect(alpha: Double, view: UIView) {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = alpha
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
    
    private func createDarkBlurEffect(alpha: Double, view: UIView) {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = alpha
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
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
    
    private func mainLibraryViewProperties() {
        mainLibraryView.backgroundColor = .clear
        mainLibraryView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        
        upperViewProperties()
        lowerViewProperties()
        textViewProperties()
        additionalInfoLabelProperties()
    }
    
    private func upperViewProperties() {
        upperView.backgroundColor = .clear
        libraryInfoEditButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        setOwnersName.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        createLightBlurEffect(alpha: 0.85, view: upperView)
    }
    
    private func lowerViewProperties() {
        lowerView.backgroundColor = .clear
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
        let int = lowerView.bounds.height + additionalInfoLabel.bounds.height + 40
        NSLayoutConstraint.activate([
            backgroundTextViewBlur.topAnchor.constraint(equalTo: additionalInfoTextView.topAnchor, constant: -int),
            backgroundTextViewBlur.leadingAnchor.constraint(equalTo: additionalInfoTextView.leadingAnchor, constant: -15),
            backgroundTextViewBlur.trailingAnchor.constraint(equalTo: additionalInfoTextView.trailingAnchor, constant: 15),
            backgroundTextViewBlur.bottomAnchor.constraint(equalTo: additionalInfoTextView.bottomAnchor, constant: 20)
        ])
    }
    
    private func additionalInfoLabelProperties() {
        let backgroundLabelBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.2
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 5
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        additionalInfoLabel.superview?.addSubview(backgroundLabelBlur)
        additionalInfoLabel.superview?.sendSubviewToBack(backgroundLabelBlur)
        NSLayoutConstraint.activate([
            backgroundLabelBlur.topAnchor.constraint(equalTo: additionalInfoLabel.topAnchor, constant: 0),
            backgroundLabelBlur.leadingAnchor.constraint(equalTo: additionalInfoLabel.leadingAnchor, constant: 0),
            backgroundLabelBlur.trailingAnchor.constraint(equalTo: additionalInfoLabel.trailingAnchor, constant: 5),
            backgroundLabelBlur.bottomAnchor.constraint(equalTo: additionalInfoLabel.bottomAnchor, constant: 0)
        ])
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let bookstoreEmail = email else { return }
        db.collection("Owners").document(bookstoreEmail).setData(["additionalInfo" : "\(additionalInfoTextView.text ?? "")"], merge: true)
    }
    
    
    @IBAction func toBookstoresButtonTapped(_ sender: Any) {
        let navc: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "navController") as! UINavigationController
        if appDelegate().currentReviewingOwnersProfile != nil {
            appDelegate().currentReviewingOwnersProfile = nil 
        }
        UIApplication.shared.keyWindow?.rootViewController = navc
    }
    
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        appDelegate().currentBookstoreOwner = nil
        let navc: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "navController") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = navc
    }
}
