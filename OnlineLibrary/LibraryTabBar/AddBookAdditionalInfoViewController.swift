//
//  AddBookAdditionalInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 19.01.2023.
//

import UIKit

class AddBookAdditionalInfoViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var additionalInfoLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Public and private functions
    private func additionalInfoTextViewSettings() {
        let backgroundTextViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.8
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
            backgroundTextViewBlur.topAnchor.constraint(equalTo: additionalInfoTextView.topAnchor, constant: -50),
            backgroundTextViewBlur.leadingAnchor.constraint(equalTo: additionalInfoTextView.leadingAnchor, constant: 0),
            backgroundTextViewBlur.trailingAnchor.constraint(equalTo: additionalInfoTextView.trailingAnchor, constant: 0),
            backgroundTextViewBlur.bottomAnchor.constraint(equalTo: additionalInfoTextView.bottomAnchor, constant: 0)
        ])
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - additionalInfoTextView.bounds.height - 50
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0)
        self.view.roundCorners(corners: [.topLeft, .topRight], radius: 15.0)
        super.updateViewConstraints()
    }
}
