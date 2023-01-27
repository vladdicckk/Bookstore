//
//  LibrarySignUpViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit

class LibrarySignUpViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var lowerView: UIView!
    
    // MARK: Lifecycle funcitons
    override func viewDidLoad() {
        super.viewDidLoad()
        upperView.setCorner(radius: 16)
        lowerView.setCorner(radius: 16)
    }
}
