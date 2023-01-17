//
//  UserSignUpViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit

class UserSignUpViewController: UIViewController{
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lowerView.setCorner(radius: 16)
        upperView.setCorner(radius: 16)
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        let userProfileVC: UserProfileViewController = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        self.navigationController?.pushViewController(userProfileVC, animated: true)
    }
}
