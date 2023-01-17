//
//  EditLibraryNameViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class EditLibraryNameViewController: UIViewController{
    @IBOutlet weak var editLibraryTitleTextField: UITextField!
    var oldLibraryTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editLibraryTitleTextField.text = oldLibraryTitle
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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let tabBarController: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
        let navVC = tabBarController.viewControllers![0] as! UINavigationController
        let libraryVC = navVC.topViewController as! LibraryViewController
        libraryVC.editedLibraryTitleLabel = editLibraryTitleTextField.text
        dismiss(animated: true)
    }
}
