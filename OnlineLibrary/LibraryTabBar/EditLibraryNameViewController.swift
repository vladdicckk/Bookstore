//
//  EditLibraryNameViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

protocol TitleSendingDelegateProtocol {
    func sendTitleDataToFirstViewController(myData: String)
}

class EditLibraryNameViewController: UIViewController{
    // MARK: Outlets
    @IBOutlet weak var editLibraryTitleTextField: UITextField!
    
    // MARK: Properties
    var delegate: TitleSendingDelegateProtocol? = nil
    var oldLibraryTitle: String?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        editLibraryTitleTextField.text = oldLibraryTitle
        mainViewProperties()
    }
    
    // MARK: Private and public functions
    private func mainViewProperties() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
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
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 800
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    // MARK: Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        if self.delegate != nil && self.editLibraryTitleTextField.text != nil {
            let dataToBeSent: String  = editLibraryTitleTextField.text ?? ""
            self.delegate?.sendTitleDataToFirstViewController(myData: dataToBeSent)
            dismiss(animated: true, completion: nil)
        }
    }
}
