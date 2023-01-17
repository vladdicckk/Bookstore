//
//  BookInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class BookInfoViewController: UIViewController{
    
    @IBOutlet weak var bookInfoView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        viewProperties()
    }
    func viewProperties(){
        let backgroundMainViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.2
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
    }
    func bookInfoViewProperties(){
        bookInfoView.backgroundColor = .clear
        bookInfoView.layer.borderColor = UIColor.black.cgColor
        bookInfoView.layer.borderWidth = 1
        bookInfoView.setCorner(radius: 16)
        
        let backgroundbookInfoViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.4
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
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
        self.view.frame.size.height = UIScreen.main.bounds.height - 300
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
}
