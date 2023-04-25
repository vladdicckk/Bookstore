//
//  UserProfileViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 14.01.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

class UserProfileViewController: UIViewController, MainInfoSendingDelegateProtocol, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var editMainInfoButton: UIButton!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var firstAndLastNamesLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var usersImageView: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var openChatsButton: UIButton!
    
    // MARK: Properties
    var reviewingChatProfileText: String?
    var arr: [ApplicationMainInfo]?
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var firstName: String?
    var lastName: String?
    var age: Int?
    var email: String?
    var phoneNumber: String?
    var username: String?
    var address: String?
    var currentImage: UIImage!
    let storage = Storage.storage().reference()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if appDelegate().currentReviewingUsersProfile == nil {
            DispatchQueue.main.async {
                self.fetchActualUserInfo(dataCompletion: { [weak self] res in
                    self?.appDelegate().currentUser = res
                    self?.firstName = res.firstName
                    self?.lastName = res.lastName
                    self?.age = res.age
                    self?.email = res.email
                    self?.phoneNumber = res.phoneNumber
                    self?.username = res.username
                    self?.address = res.location
                    self?.userInfoConfiguration()
                })
            }
        } else {
            userInfoConfiguration()
        }
        
        navigationController?.isNavigationBarHidden = true
        imageViewProperties()
        viewProperties()
        NSLayoutConstraint.activate([upperView.widthAnchor.constraint(equalToConstant: view.width/1.75)])
        var emailForImageDownloading = "."
        if appDelegate().currentReviewingUsersProfile != nil {
            emailForImageDownloading = email ?? "."
        } else {
            emailForImageDownloading = appDelegate().currentEmail ?? "."
        }
        
        firestoreManager.getUserAvatarURL(email: emailForImageDownloading, completion: {[weak self] url in
            DispatchQueue.global().async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // Create Image and Update Image View
                        self?.usersImageView.image = self?.setProfileImage(imageToResize: (UIImage(data: data) ?? UIImage(named: "empty"))!, onImageView: self?.usersImageView ?? UIImageView())
                    }
                }
            }
        })
        
        if appDelegate().currentReviewingUsersProfile != nil && appDelegate().currentReviewingUsersProfile != appDelegate().currentUser {
            openChatsButton.isHidden = true
            logoutButton.isHidden = true
            editMainInfoButton.isHidden = true
        } else {
            openChatsButton.isHidden = false
            logoutButton.isHidden = false
            editMainInfoButton.isHidden = false
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        usersImageView.isUserInteractionEnabled = true
        usersImageView.addGestureRecognizer(tapGestureRecognizer)
        
        if reviewingChatProfileText != "" && reviewingChatProfileText != nil {
            logoutButton.setTitle(reviewingChatProfileText, for: .normal)
            logoutButton.isHidden = false
        }
     }
    
    // MARK: Private and public functions
    private func fetchActualUserInfo(dataCompletion: @escaping (User) -> Void) {
        guard let email = appDelegate().currentEmail else { return }
        firestoreManager.getUserInfo(email: email, completion: { user in
            dataCompletion(user)
        })
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        if appDelegate().currentReviewingUsersProfile == nil {
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
        usersImageView.layer.borderWidth = 2.5
        usersImageView.layer.borderColor = UIColor.gray.cgColor
        usersImageView.backgroundColor = .gray
        usersImageView.contentMode = .scaleAspectFill
        usersImageView.layer.cornerRadius = 121.5/2
        usersImageView.layer.masksToBounds = true
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
    
    private func userInfoConfiguration() {
        greetingLabel.text = "Hello, \(appDelegate().currentUser?.firstName ?? appDelegate().currentBookstoreOwner?.ownersName ?? "")"
        if greetingLabel.text == "Hello, " {
            greetingLabel.text = "User profile"
        }
        usernameInfoLabel.text = username
        emailLabel.text = email
        addressLabel.text = address
        phoneNumberLabel.text = phoneNumber
        firstAndLastNamesLabel.text = "\(firstName ?? "") \(lastName ?? "")"
        ageLabel.text = "\(age ?? 0)"
    }

    func sendMainInfoDataToFirstViewController(phoneNumber: String, location: String) {
        phoneNumberLabel.text = phoneNumber
        addressLabel.text = location
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getMainInfoDataSegue" {
            let editProfileInfoVC: EditUserMainInfoViewController = segue.destination as! EditUserMainInfoViewController
            editProfileInfoVC.userEmail = email
            editProfileInfoVC.oldPhoneNumber = phoneNumberLabel.text
            editProfileInfoVC.oldAddress = addressLabel.text
            editProfileInfoVC.delegate = self
        }
    }

    private func viewProperties() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        editMainInfoButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        createLightBlurEffect(alpha: 0.85, view: userInfoView, clipsToBounds: true)
        
        upperViewProperties()
        greetingLabelProperties()
    }

    private func createLightBlurEffect(alpha: Double, view: UIView, clipsToBounds: Bool) {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = alpha
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = clipsToBounds
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
    
    private func upperViewProperties() {
        upperView.layer.cornerRadius = 16
        upperView.backgroundColor = .clear
         
        createLightBlurEffect(alpha: 0.75, view: upperView, clipsToBounds: true)
    }

    private func greetingLabelProperties() {
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 25)
        greetingLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 1)
    }
    
    // MARK: - Actions
    @IBAction func openChatsButtonTapped(_ sender: Any) {
        appDelegate().currentReviewingUsersProfile = nil
        
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        let navVc: UINavigationController = chatStoryboard.instantiateViewController(withIdentifier: "ChatNavVC") as! UINavigationController
        let vc = navVc.topViewController as! ChatsViewController
        vc.chatUserImage = usersImageView.image
        UIApplication.shared.keyWindow?.rootViewController = navVc
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        if reviewingChatProfileText != nil && reviewingChatProfileText != "" {
            let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
            let vc: UINavigationController = chatStoryboard.instantiateViewController(withIdentifier: "ChatNavVC") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = vc
        } else {
            appDelegate().currentUser = nil
            let navc: UINavigationController = self.storyboard?.instantiateViewController(withIdentifier: "navController") as! UINavigationController
            do {
                try FirebaseAuth.Auth.auth().signOut()
            } catch {
                print("Failed to log out")
            }
            UIApplication.shared.keyWindow?.rootViewController = navc
        }
    }

    @IBAction func toBookstoresButtonTapped(_ sender: Any) {
        let navVc = storyboard?.instantiateViewController(withIdentifier: "navController") as! UINavigationController
        let vc: ViewController = navVc.topViewController as! ViewController
        UIApplication.shared.keyWindow?.rootViewController = vc
    }
    
    @IBAction func showApplications(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "UserTradingHistoryViewController") as! UserTradingHistoryViewController
        vc.arr = arr
        present(vc, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        guard let data = setProfileImage(imageToResize: image, onImageView: usersImageView).pngData() else { return }
        
        dismiss(animated: true)
        
        usersImageView.image = setProfileImage(imageToResize: image, onImageView: usersImageView)
        guard let username = username else { return }
        storage.child("images.\(username)_Avatar.png").putData(data, completion: {[weak self]  _, err in
            guard err == nil else {
                print("Failed to upload")
                return
            }
            self?.storage.child("images.\(username)_Avatar.png").downloadURL(completion: {[weak self]  url, err in
                guard let url = url, err == nil else { return }
                let urlString = url.absoluteString

                guard let email = self?.email else {
                    print("Empty email")
                    return
                }

                self?.db.collection("Users").document(email).setData(["AvatarImageURL" : urlString], merge: true)
            })
        })
        
    }
}
