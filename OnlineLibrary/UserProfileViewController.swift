//
//  UserProfileViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 14.01.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MainInfoSendingDelegateProtocol, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // MARK: Outlets
    @IBOutlet weak var applicationsView: UIView!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var editMainInfoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var tradingHistoryLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var firstAndLastNamesLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var usersImageView: UIImageView!
    
    // MARK: Properties
    var arr: [ApplicationMainInfo]?
    let db = Firestore.firestore()
    var firstName: String?
    var lastName: String?
    var age: Int?
    var email: String?
    var phoneNumber: String?
    var username: String?
    var address: String?
    var currentImage: UIImage!
    
    // MARK: Lifecycle functions
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TradingHistoryCell")
        self.navigationController?.isNavigationBarHidden = true
        imageViewProperties()
        userInfoConfiguration()
        viewProperties()
        if currentImage != nil {
            self.usersImageView.image = currentImage
        } else {
            let image = UIImage(systemName: "photo")
            self.usersImageView.image = image
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        usersImageView.isUserInteractionEnabled = true
        usersImageView.addGestureRecognizer(tapGestureRecognizer)
     }
    
    // MARK: Private and public functions
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        importPicture()
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func imageViewProperties() {
        usersImageView.layer.borderWidth = 2.5
        usersImageView.layer.masksToBounds = false
        usersImageView.layer.borderColor = UIColor.gray.cgColor
        usersImageView.layer.cornerRadius = usersImageView.frame.height/2
        usersImageView.sizeToFit()
        usersImageView.clipsToBounds = true
        
        usersImageView.contentMode = .center
        
        usersImageView.backgroundColor = .gray
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
        greetingLabel.text = "Hello, \(firstName ?? "")"
        usernameInfoLabel.text = username
        emailLabel.text = email
        addressLabel.text = address
        phoneNumberLabel.text = phoneNumber
        firstAndLastNamesLabel.text = "\(firstName ?? "") \(lastName ?? "")"
        ageLabel.text = "\(age ?? 0)"
    }

    func sendMainInfoDataToFirstViewController(phoneNumber: String, location: String, username: String) {
        phoneNumberLabel.text = phoneNumber
        addressLabel.text = location
        usernameInfoLabel.text = username
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getMainInfoDataSegue" {
            let editProfileInfoVC: EditUserMainInfoViewController = segue.destination as! EditUserMainInfoViewController
            editProfileInfoVC.userEmail = email
            editProfileInfoVC.oldPhoneNumber = phoneNumberLabel.text
            editProfileInfoVC.oldAddress = addressLabel.text
            editProfileInfoVC.oldUsername = usernameInfoLabel.text
            editProfileInfoVC.delegate = self
        }
    }

    private func viewProperties() {
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        editMainInfoButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        createLightBlurEffect(alpha: 0.85, view: userInfoView, clipsToBounds: true)
        
        upperViewProperties()
        greetingLabelProperties()
        tradingHistoryLabelProperties()
        applicationsViewProperties()
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
    
    private func applicationsViewProperties() {
        applicationsView.layer.cornerRadius = 16
        applicationsView.backgroundColor = .clear
         
        createLightBlurEffect(alpha: 0.75, view: applicationsView, clipsToBounds: true)
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

    private func tradingHistoryLabelProperties() {
        tradingHistoryLabel.font = UIFont.boldSystemFont(ofSize: 27)
        tradingHistoryLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 1)
    }

    @IBAction func toBookstoresButtonTapped(_ sender: Any) {
        let vc: ViewController = storyboard?.instantiateViewController(withIdentifier: "ViewController")  as! ViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    

    // MARK: UITableViewDataSource & UITableViewDelegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arr?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradingHistoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        guard let arr = arr else { return cell }
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.textProperties.font = UIFont.boldSystemFont(ofSize: 17)
        content.text = "Book title: \(arr[indexPath.row].book.title), Author: \(arr[indexPath.row].book.author)"
        if arr[indexPath.row].type != "" {
            if arr[indexPath.row].status {
                content.secondaryText = "\(arr[indexPath.row].type). Status: Success"
            } else {
                content.secondaryText = "\(arr[indexPath.row].type). Status: Failure"
            }
        } else {
            if arr[indexPath.row].status {
                content.secondaryText = "Status: Success"
            } else {
                content.secondaryText = "Status: Failure"
            }
        }
        
        let backgroundTableViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.8
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        tableView.backgroundView = backgroundTableViewBlur
        
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 1
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        cell.backgroundView = backgroundBlur
        cell.selectedBackgroundView = cell.backgroundView
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.selectedBackgroundView?.layer.cornerRadius = 16
        cell.layer.cornerRadius = 16
        cell.backgroundColor = .clear
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let arr = arr else { return }
        let vc: ApplicationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ApplicationViewController") as! ApplicationViewController
        vc.application = arr[indexPath.row]
        present(vc, animated: true)
    }
    
    // MARK: UIImagePickerControllerDelegate & UINavigationControllerDelegate function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        self.usersImageView.image = setProfileImage(imageToResize: image, onImageView: usersImageView)
    }
}
