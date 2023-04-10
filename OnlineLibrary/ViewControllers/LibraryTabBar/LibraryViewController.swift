//
//  LibraryViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 07.01.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class LibraryViewController: UIViewController, UITextViewDelegate, MainSendingDelegateProtocol, NameSendingDelegateProtocol, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet var mainLibraryView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var ownersName: UILabel!
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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var openChatsButton: UIButton!
    
    // MARK: Parameters
    var reviewingChatProfileText: String?
    var bookstoreName: String?
    var address: String?
    var phoneNumber: String?
    var preference: String?
    var email: String?
    var bookstoreOwnersName: String?
    var additionalInfoText: String?
    var currentImage: UIImage!
    let firestoreManager = FirestoreManager()
    let storage = Storage.storage().reference()
    let db = Firestore.firestore()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        accessSettings()
        bookstoreInfoConfiguration()
        mainLibraryViewProperties()
        imageViewProperties()
        
        if reviewingChatProfileText != "" && reviewingChatProfileText != nil {
            logoutButton.setTitle(reviewingChatProfileText, for: .normal)
            logoutButton.isHidden = false
        }
        
        self.firestoreManager.getBookstoreAvatarURL(email: self.email ?? appDelegate().currentReviewingOwnersProfile?.email ?? "", completion: { url in
            DispatchQueue.global().async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // Create Image and Update Image View
                        self.imageView.image = self.setProfileImage(imageToResize: UIImage(data: data)!, onImageView: self.imageView)
                    }
                }
            }
        })
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        self.title = bookstoreName
        navigationController?.navigationBar.prefersLargeTitles = true
        upperView.isHidden = false
    }
    
    // MARK: Private and public functions
    private func accessSettings() {
        
        if appDelegate().currentReviewingOwnersProfile != nil && appDelegate().currentBookstoreOwner != nil && appDelegate().currentReviewingOwnersProfile != appDelegate().currentBookstoreOwner {
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
        } else {
            libraryInfoEditButton.isHidden = false
            setOwnersName.isHidden = false
            saveAdditionalInfoDataButton.isHidden = false
            additionalInfoTextView.isEditable = true
            if #available(iOS 16.0, *) {
                logoutButton.isHidden = false
            } else {
                logoutButton.isEnabled = true
                // Fallback on earlier versions
            }
        }
        
        if appDelegate().currentReviewingOwnersProfile != nil && appDelegate().currentReviewingOwnersProfile != appDelegate().currentBookstoreOwner {
            self.tabBarController?.viewControllers?.remove(at: 3)
            openChatsButton.isHidden = true
        } else {
            openChatsButton.isHidden = false
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if appDelegate().currentReviewingOwnersProfile == nil {
            importPicture()
        }
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func imageViewProperties() {
        imageView.image = setProfileImage(imageToResize: UIImage(named: "empty")!, onImageView: imageView)
        
        imageView.layer.borderWidth = 2.5
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.cornerRadius = imageView.frame.width/2
        
        imageView.sizeToFit()
        imageView.clipsToBounds = true
        
        imageView.contentMode = .center
        
        imageView.backgroundColor = .gray
    }
    
    func setProfileImage(imageToResize: UIImage, onImageView: UIImageView) -> UIImage {
        let width = imageToResize.size.width
        let height = imageToResize.size.height

        var scaleFactor: CGFloat

        if width > height {
            scaleFactor = onImageView.frame.size.height / height;
        }
        else {
            scaleFactor = onImageView.frame.size.width / width;
        }

        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width * scaleFactor, height * scaleFactor), false, 0.0)
        imageToResize.draw(in: CGRectMake(0, 0, width * scaleFactor, height * scaleFactor))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? UIImage()
    }

    private func bookstoreInfoConfiguration() {
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
        contactPhoneLabel.text = phoneNumber
        locationLabel.text = location
        typeOfTrading.text = preferences
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getMainDataSegue" {
            let editLibraryInfoVC: EditLibraryInfoViewController = segue.destination as! EditLibraryInfoViewController
            editLibraryInfoVC.bookStoreOwnersEmail = email
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
    @IBAction func opennChatsButtonTapped(_ sender: Any) {
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let vc: UINavigationController = chatStoryboard.instantiateViewController(withIdentifier: "ChatNavVC") as! UINavigationController
        UIApplication.shared.keyWindow?.rootViewController = vc
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
        if reviewingChatProfileText != nil && reviewingChatProfileText != "" {
            let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc: UINavigationController = chatStoryboard.instantiateViewController(withIdentifier: "ChatNavVC") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
        } else {
            appDelegate().currentBookstoreOwner = nil
            let navc: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "navController") as! UINavigationController
            do {
                try FirebaseAuth.Auth.auth().signOut()
            } catch {
                print("Failed to log out")
            }
            UIApplication.shared.keyWindow?.rootViewController = navc
        }
    }
    
    // MARK: UIImagePickerControllerDelegate & UINavigationControllerDelegate function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        guard let data = setProfileImage(imageToResize: image, onImageView: imageView).pngData() else { return }
        
        dismiss(animated: true)
        
        self.imageView.image = setProfileImage(imageToResize: image, onImageView: imageView)
        guard let bookstoreName = bookstoreName else { return }
        storage.child("images.\(bookstoreName)_Avatar.png").putData(data, completion: { _, err in
            guard err == nil else {
                print("Failed to upload")
                return
            }
            self.storage.child("images.\(bookstoreName)_Avatar.png").downloadURL(completion: { url, err in
                guard let url = url, err == nil else { return }
                let urlString = url.absoluteString

                guard let email = self.email else {
                    print("Empty email")
                    return
                }

                self.db.collection("Owners").document(email).setData(["AvatarImageURL" : urlString], merge: true)
            })
        })
    }
}

