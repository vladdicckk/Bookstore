//
//  BookInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class BookInfoViewController: UIViewController{
    // MARK: Outlets
    @IBOutlet weak var bookAdditionalInfoTextView: UITextView!
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var bookInfoView: UIView!
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        viewProperties()
    }
    
    // MARK: Private and public functions
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
    
    private func viewProperties() {
        createLightBlurEffect(alpha: 0.35, view: view)
        bookInfoViewProperties()
        mainInfoViewProperties()
        bookAdditionalInfoTextViewProperties()
    }
    
    private func mainInfoViewProperties() {
        mainInfoView.setCorner(radius: 16)
        mainInfoView.layer.borderColor = UIColor.black.cgColor
        mainInfoView.layer.borderWidth = 1
    }
    
    private func bookAdditionalInfoTextViewProperties() {
        bookAdditionalInfoTextView.setCorner(radius: 16)
        bookAdditionalInfoTextView.layer.borderColor = UIColor.black.cgColor
        bookAdditionalInfoTextView.layer.borderWidth = 1
        bookAdditionalInfoTextView.backgroundColor = .clear
        
        let backgroundTextViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.6
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        bookAdditionalInfoTextView.superview?.addSubview(backgroundTextViewBlur)
        bookAdditionalInfoTextView.superview?.sendSubviewToBack(backgroundTextViewBlur)
        
        backgroundTextViewBlur.translatesAutoresizingMaskIntoConstraints  = false
        
        NSLayoutConstraint.activate([
            backgroundTextViewBlur.topAnchor.constraint(equalTo: bookAdditionalInfoTextView.topAnchor, constant: 0),
            backgroundTextViewBlur.leadingAnchor.constraint(equalTo: bookAdditionalInfoTextView.leadingAnchor, constant: 0),
            backgroundTextViewBlur.trailingAnchor.constraint(equalTo: bookAdditionalInfoTextView.trailingAnchor, constant: 0),
            backgroundTextViewBlur.bottomAnchor.constraint(equalTo: bookAdditionalInfoTextView.bottomAnchor, constant: 0)
        ])
    }
    
    private func bookInfoViewProperties() {
        bookInfoView.backgroundColor = .clear
        bookInfoView.layer.borderColor = UIColor.black.cgColor
        bookInfoView.layer.borderWidth = 1
        bookInfoView.setCorner(radius: 16)
        
        createLightBlurEffect(alpha: 0.55, view: bookInfoView)
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 150
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
}
