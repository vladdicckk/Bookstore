//
//  LibraryViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 07.01.2023.
//

import UIKit

class LibraryViewController: UIViewController, TitleSendingDelegateProtocol, MainSendingDelegateProtocol, NameSendingDelegateProtocol{
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainLibraryViewProperties()
    }
    
    
    func mainLibraryViewProperties(){
        mainLibraryView.backgroundColor = .clear
        mainLibraryView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        let backgroundMainViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.35
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        mainLibraryView.addSubview(backgroundMainViewBlur)
        mainLibraryView.sendSubviewToBack(backgroundMainViewBlur)
        
        backgroundMainViewBlur.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundMainViewBlur.topAnchor.constraint(equalTo: mainLibraryView.topAnchor, constant: 0),
            backgroundMainViewBlur.leadingAnchor.constraint(equalTo: mainLibraryView.leadingAnchor, constant: 0),
            backgroundMainViewBlur.trailingAnchor.constraint(equalTo: mainLibraryView.trailingAnchor, constant: 0),
            backgroundMainViewBlur.bottomAnchor.constraint(equalTo: mainLibraryView.bottomAnchor, constant: 0)
        ])
        upperViewProperties()
        lowerViewProperties()
        textViewProperties()
        additionalInfoLabelProperties()
    }
    
    func upperViewProperties(){
        upperView.backgroundColor = .clear
        editLibraryNameButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        libraryInfoEditButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        setOwnersName.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        
        let backgroundUpperViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.55
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        upperView.addSubview(backgroundUpperViewBlur)
        upperView.sendSubviewToBack(backgroundUpperViewBlur)
        
        backgroundUpperViewBlur.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundUpperViewBlur.topAnchor.constraint(equalTo: upperView.topAnchor, constant: 0),
            backgroundUpperViewBlur.leadingAnchor.constraint(equalTo: upperView.leadingAnchor, constant: 0),
            backgroundUpperViewBlur.trailingAnchor.constraint(equalTo: upperView.trailingAnchor, constant: 0),
            backgroundUpperViewBlur.bottomAnchor.constraint(equalTo: upperView.bottomAnchor, constant: 0)
        ])
    }
    
    func lowerViewProperties(){
        lowerView.backgroundColor = .clear
        
        let backgroundLowerViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.45
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        lowerView.addSubview(backgroundLowerViewBlur)
        lowerView.sendSubviewToBack(backgroundLowerViewBlur)
        backgroundLowerViewBlur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundLowerViewBlur.topAnchor.constraint(equalTo: lowerView.topAnchor, constant: 0),
            backgroundLowerViewBlur.leadingAnchor.constraint(equalTo: lowerView.leadingAnchor, constant: -20),
            backgroundLowerViewBlur.trailingAnchor.constraint(equalTo: lowerView.trailingAnchor, constant: 20),
            backgroundLowerViewBlur.bottomAnchor.constraint(equalTo: lowerView.bottomAnchor, constant: 0)
        ])
    }
    
    func textViewProperties(){
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
    func additionalInfoLabelProperties(){
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
