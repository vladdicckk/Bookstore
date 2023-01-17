//
//  EditLibraryInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class EditLibraryInfoViewController: UIViewController{

    @IBOutlet weak var editOwnerEmailTextField: UITextField!
    @IBOutlet weak var editOwnerPhoneNumberTextField: UITextField!
    @IBOutlet weak var editLibraryLocationTextField: UITextField!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var choosingExchangeButton: UIButton!
    @IBOutlet weak var choosingTradeButton: UIButton!
    var oldLibraryLocation: String?
    var oldOwnerPhoneNumber: String?
    var oldOwnerEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainViewProperties()
    }
    
    func mainViewProperties(){
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.darkGray
            blurView.clipsToBounds = true
            return blurView
        }()
        mainView.addSubview(backgroundBlur)
        mainView.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            backgroundBlur.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            backgroundBlur.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            backgroundBlur.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0)
        ])
    }
    func editedTextFields(){
        
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = self.mainView.frame.size.height
        self.view.frame.size.width = self.mainView.frame.size.width
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
}
