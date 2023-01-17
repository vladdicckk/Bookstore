//
//  LibraryViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 07.01.2023.
//

import UIKit

class LibraryViewController: UIViewController{
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
    var editedLibraryTitleLabel: String?
    var editedOwnerEmailLabel: String?
    var editedOwnerLocationLabel: String?
    var editedOwnerPhoneNumberLabel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainLibraryViewProperties()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if editedLibraryTitleLabel != nil{
            libraryTitleLabel.text = editedLibraryTitleLabel
            
        }
    }
    
    func mainLibraryViewProperties(){
        mainLibraryView.backgroundColor = .clear
        mainLibraryView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        let backgroundMainViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.15
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
        
        let backgroundUpperViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.4
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
            blurView.alpha = 0.3
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
            blurView.alpha = 0.5
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
            blurView.alpha = 0.1
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 5
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
    
    @IBAction func editLibraryTitleButtonTapped(_ sender: Any) {
        let editLibraryTitleVC: EditLibraryNameViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditLibraryNameViewController") as! EditLibraryNameViewController
        editLibraryTitleVC.oldLibraryTitle = libraryTitleLabel.text
        present(editLibraryTitleVC, animated: true)
    }
    @IBAction func editLibraryInfoButtonTapped(_ sender: Any) {
        let editLibraryInfoVC: EditLibraryInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditLibraryInfoViewController") as! EditLibraryInfoViewController
        editLibraryInfoVC.oldOwnerEmail = emailLabel.text
        editLibraryInfoVC.oldOwnerPhoneNumber = contactPhoneLabel.text
        editLibraryInfoVC.oldLibraryLocation = locationLabel.text
        present(editLibraryInfoVC, animated: true)
    }
}
