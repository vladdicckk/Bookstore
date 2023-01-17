//
//  LibrarySignUpViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit

class LibrarySignUpViewController: UIViewController{
    
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        upperView.setCorner(radius: 16)
        lowerView.setCorner(radius: 16)
    }
}
