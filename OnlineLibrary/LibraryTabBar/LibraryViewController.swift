//
//  LibraryViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 07.01.2023.
//

import UIKit

class LibraryViewController: UIViewController, TitleSendingDelegateProtocol, MainSendingDelegateProtocol, NameSendingDelegateProtocol{
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet var mainLibraryView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var libraryTitleLabel: UILabel!
    @IBOutlet weak var ownersName: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contactPhoneLabel: UILabel!
    @IBOutlet weak var typeOfTrading: UILabel!
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var editLibraryNameButton: UIButton!
    @IBOutlet weak var libraryInfoEditButton: UIButton!
    @IBOutlet weak var setOwnersName: UIButton!
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mainLibraryViewProperties()
    }
    
    // MARK: Private and public functions
    func sendTitleDataToFirstViewController(myData: String) {
        libraryTitleLabel.text = myData
    }
    
    func sendNameDataToFirstViewController(name: String) {
        ownersName.text = name
    }
    
    func sendMainDataToFirstViewController(email: String, phoneNumber: String, location: String, preferences: String) {
        emailLabel.text = email
        contactPhoneLabel.text = phoneNumber
        locationLabel.text = location
        typeOfTrading.text = preferences
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getTitleDataSegue" {
            let editTitleVC: EditLibraryNameViewController = segue.destination as! EditLibraryNameViewController
            editTitleVC.oldLibraryTitle = libraryTitleLabel.text
            editTitleVC.delegate = self
        }
        if segue.identifier == "getMainDataSegue"{
            let editLibraryInfoVC: EditLibraryInfoViewController = segue.destination as! EditLibraryInfoViewController
            editLibraryInfoVC.oldOwnerEmail = emailLabel.text
            editLibraryInfoVC.oldOwnerPhoneNumber = contactPhoneLabel.text
            editLibraryInfoVC.oldLibraryLocation = locationLabel.text
            editLibraryInfoVC.oldOwnerPreferences = typeOfTrading.text
            editLibraryInfoVC.delegate = self
        }
        if segue.identifier == "getNameData"{
            let setNameVC: SetLibraryOwnerName = segue.destination as! SetLibraryOwnerName
            setNameVC.setName = ownersName.text
            setNameVC.delegate = self
        }
    }
    
    private func createLightBlurEffect(alpha: Double, view: UIView) {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
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
    
    private func mainLibraryViewProperties(){
        mainLibraryView.backgroundColor = .clear
        mainLibraryView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        createDarkBlurEffect(alpha: 0.35, view: mainLibraryView)
        
        upperViewProperties()
        lowerViewProperties()
        textViewProperties()
        additionalInfoLabelProperties()
    }
    
    private func upperViewProperties(){
        upperView.backgroundColor = .clear
        editLibraryNameButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        libraryInfoEditButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        setOwnersName.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        createDarkBlurEffect(alpha: 0.55, view: upperView)
    }
    
    private func lowerViewProperties(){
        lowerView.backgroundColor = .clear
        createLightBlurEffect(alpha: 0.45, view: lowerView)
    }
    
    private func textViewProperties(){
        additionalInfoTextView.backgroundColor = .clear
        
        let backgroundTextViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.75
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
            backgroundTextViewBlur.topAnchor.constraint(equalTo: additionalInfoTextView.topAnchor, constant: -40),
            backgroundTextViewBlur.leadingAnchor.constraint(equalTo: additionalInfoTextView.leadingAnchor, constant: 0),
            backgroundTextViewBlur.trailingAnchor.constraint(equalTo: additionalInfoTextView.trailingAnchor, constant: 0),
            backgroundTextViewBlur.bottomAnchor.constraint(equalTo: additionalInfoTextView.bottomAnchor, constant: 0)
        ])
    }
    
    private func additionalInfoLabelProperties(){
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
}
