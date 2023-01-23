//
//  BookInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class BookInfoViewController: UIViewController{
    
    @IBOutlet weak var bookAdditionalInfoTextView: UITextView!
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var bookInfoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        viewProperties()
    }
    func viewProperties() {
        let backgroundMainViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.35
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        view.addSubview(backgroundMainViewBlur)
        view.sendSubviewToBack(backgroundMainViewBlur)
        NSLayoutConstraint.activate([
            backgroundMainViewBlur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundMainViewBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundMainViewBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            backgroundMainViewBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        bookInfoViewProperties()
        mainInfoViewProperties()
        bookAdditionalInfoTextViewProperties()
    }
    func mainInfoViewProperties(){
        mainInfoView.setCorner(radius: 16)
        mainInfoView.layer.borderColor = UIColor.black.cgColor
        mainInfoView.layer.borderWidth = 1
    }
    
    func bookAdditionalInfoTextViewProperties() {
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
    
    func bookInfoViewProperties() {
        bookInfoView.backgroundColor = .clear
        bookInfoView.layer.borderColor = UIColor.black.cgColor
        bookInfoView.layer.borderWidth = 1
        bookInfoView.setCorner(radius: 16)
        
        let backgroundbookInfoViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.55
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        bookInfoView.addSubview(backgroundbookInfoViewBlur)
        bookInfoView.sendSubviewToBack(backgroundbookInfoViewBlur)
        NSLayoutConstraint.activate([
            backgroundbookInfoViewBlur.topAnchor.constraint(equalTo: bookInfoView.topAnchor, constant: 0),
            backgroundbookInfoViewBlur.leadingAnchor.constraint(equalTo: bookInfoView.leadingAnchor, constant: 0),
            backgroundbookInfoViewBlur.trailingAnchor.constraint(equalTo: bookInfoView.trailingAnchor, constant: 0),
            backgroundbookInfoViewBlur.bottomAnchor.constraint(equalTo: bookInfoView.bottomAnchor, constant: 0)
        ])
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 150
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
}
