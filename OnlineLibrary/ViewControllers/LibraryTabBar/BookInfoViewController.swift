//
//  BookInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class BookInfoViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var bookAdditionalInfoTextView: UITextView!
    @IBOutlet weak var mainInfoView: UIView!
    @IBOutlet weak var bookInfoView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    @IBOutlet weak var pagesCountLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var publishYearLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var openApplicationCreatingButton: UIButton!
    
    // MARK: Parameters
    var bookTitle: String?
    var author: String?
    var publishYear: Int?
    var language: String?
    var pagesCount: Int?
    var additionalInfo: String?
    var genre: String?
    var price: Double?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        securityProperties()
        viewProperties()
        configureBookInfo()
    }
    
    // MARK: Private and public functions
    func securityProperties() {
        if appDelegate().currentBookstoreOwner == nil {
            additionalInfoTextView.isEditable = false
        }
        
        if appDelegate().currentUser == nil {
            openApplicationCreatingButton.isHidden = true
        }
        
        if appDelegate().currentBookstoreOwner != nil && appDelegate().currentReviewingOwnersProfile != nil {
            additionalInfoTextView.isEditable = false
        }
    }
    
    func configureBookInfo() {
        bookTitleLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        authorLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        publishYearLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        languageLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        pagesCountLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        additionalInfoTextView.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        genreLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        priceLabel.textColor = UIColor(red: 255/255, green: 238/255, blue: 169/255, alpha: 1)
        
        bookTitleLabel.text = "Title: \(bookTitle ?? "")"
        authorLabel.text = "Author: \(author ?? "")"
        publishYearLabel.text = "Publish year: \(publishYear ?? 0)"
        languageLabel.text = "Language: \(language ?? "")"
        pagesCountLabel.text = "Pages count: \(pagesCount ?? 0)"
        additionalInfoTextView.text = "Additional info: \(additionalInfo ?? "")"
        genreLabel.text = "Genre: \(genre ?? "")"
        priceLabel.text = "Price: \(price ?? 0)"
    }
    
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
        createLightBlurEffect(alpha: 0.85, view: view)
        bookInfoViewProperties()
        mainInfoViewProperties()
        bookAdditionalInfoTextViewProperties()
    }
    
    private func mainInfoViewProperties() {
        mainInfoView.setCorner(radius: 16)
        mainInfoView.layer.borderColor = UIColor.brown.cgColor
        mainInfoView.layer.borderWidth = 1
    }
    
    private func bookAdditionalInfoTextViewProperties() {
        bookAdditionalInfoTextView.setCorner(radius: 16)
        bookAdditionalInfoTextView.layer.borderColor = UIColor.brown.cgColor
        bookAdditionalInfoTextView.layer.borderWidth = 1
        bookAdditionalInfoTextView.backgroundColor = .clear
        
        let backgroundTextViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.75
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
        bookInfoView.layer.borderColor = UIColor.brown.cgColor
        bookInfoView.layer.borderWidth = 1
        bookInfoView.setCorner(radius: 16)
        
        createDarkBlurEffect(alpha: 0.75, view: bookInfoView)
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 150
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    @IBAction func openApplicationCreatingButtonTaapped(_ sender: Any) {
        let vc: SendApplicationToBookstoreViewController = storyboard?.instantiateViewController(withIdentifier: "SendApplicationToBookstoreViewController") as! SendApplicationToBookstoreViewController
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .fullScreen
        vc.storyboardPrevious = self.storyboard
        vc.book = BookInfo(title: bookTitle ?? "", author: author ?? "", publishYear: publishYear ?? 0, genre: genre ?? "", pagesCount: pagesCount ?? 0, language: language ?? "", price: price ?? 0, additionalInfo: additionalInfo ?? "", addingDate: "")
        present(vc, animated: true)
    }
}
