//
//  UserProfileViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 14.01.2023.
//

import UIKit

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MainInfoSendingDelegateProtocol {
    // MARK: Outlets
    @IBOutlet weak var editMainInfoButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userInfoView: UIView!
    @IBOutlet weak var tradingHistoryLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var usernameInfoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    // MARK: Properties
    var arr: [String] = ["Object ","Object ","Object ","Object ","Object "]
    var showLibrariesButton: UIBarButtonItem = UIBarButtonItem()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TradingHistoryCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "To libraries", style: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        viewProperties()
    }
    
    // MARK: Private and public functions
    func sendMainInfoDataToFirstViewController(email: String, phoneNumber: String, location: String, username: String) {
        emailLabel.text = email
        phoneNumberLabel.text = phoneNumber
        addressLabel.text = location
        usernameInfoLabel.text = username
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getMainInfoDataSegue"{
            let editProfileInfoVC: EditUserMainInfoViewController = segue.destination as! EditUserMainInfoViewController
            editProfileInfoVC.oldEmail = emailLabel.text
            editProfileInfoVC.oldPhoneNumber = phoneNumberLabel.text
            editProfileInfoVC.oldAddress = addressLabel.text
            editProfileInfoVC.oldUsername = usernameInfoLabel.text
            editProfileInfoVC.delegate = self
        }
    }
    
    private func viewProperties(){
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        editMainInfoButton.setImage(UIImage(systemName: "pencil.line"), for: .normal)
        
        createLightBlurEffect(alpha: 0.6, view: view)
        createLightBlurEffect(alpha: 0.45, view: userInfoView)
        
        greetingLabelProperties()
        tradingHistoryLabelProperties()
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
    
    private func greetingLabelProperties() {
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 25)
        greetingLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 1)
    }
    
    private func tradingHistoryLabelProperties() {
        tradingHistoryLabel.font = UIFont.boldSystemFont(ofSize: 24)
        tradingHistoryLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.4, alpha: 1)
    }
    
    @objc func done() {
        let librariesVC: LibrariesViewController = storyboard?.instantiateViewController(withIdentifier: "LibrariesViewController")  as! LibrariesViewController
        navigationController?.pushViewController(librariesVC, animated: true)
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradingHistoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.textProperties.font = UIFont.boldSystemFont(ofSize: 17)
        content.text = arr[indexPath.row] + "\(indexPath.row + 1)"
        
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.45
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        cell.backgroundView = backgroundBlur
        cell.backgroundColor = .clear
        cell.contentConfiguration = content
        return cell
    }
}
