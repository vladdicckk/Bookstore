//
//  SendApplicationToBookstoreViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 13.02.2023.
//

import UIKit
import FirebaseFirestore

class SendApplicationToBookstoreViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: Outlets
    @IBOutlet weak var preferenceLabel: UILabel!
    @IBOutlet weak var upperView: UILabel!
    @IBOutlet weak var additionalinfoTextView: UITextView!
    @IBOutlet weak var usersInfoTextView: UITextView!
    @IBOutlet weak var preferenceTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: Parameters
    var storyboardPrevious: UIStoryboard?
    let db = Firestore.firestore()
    var book: BookInfo?
    var preferences: [String] = ["Trading","Exchanging","Both"]
    var rolesPicker = UIPickerView()
    var selectedIndex: Int = 0
    var toolBar = UIToolbar()
    let firestoreManager = FirestoreManager()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        prefillUserInfo()
        
        preferenceTextField.text = "Trading"
        preferenceTextField.isEnabled = false
    }
    
    private func prefillUserInfo() {
        guard let user = appDelegate().currentUser else { print("user data empty")
            return }
        usersInfoTextView.text = "Name: \(user.firstName) Surname: \(user.lastName) Age: \(user.age) \nE-mail address: \(user.email) \nLocation: \(user.location) \nPhone number: \(user.phoneNumber)"
    }
    
    private func viewSetup() {
        view.backgroundColor = .clear
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 1
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
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Send application and open chat
    @IBAction func sendApplicationButtonTapped(_ sender: UIButton) {
        guard let bookstore = appDelegate().currentReviewingOwnersProfile else { print("bookstore data empty")
            return }
        guard let book = book else { print("book data empty")
            return }
        guard let user = appDelegate().currentUser else { print("book data empty")
            return }
        
        guard let email = appDelegate().currentEmail else { print("email empty")
            return }
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        // again convert your date to string
        let myStringDate = formatter.string(from: yourDate!)
        
        let application = Application(userInfo: usersInfoTextView.text, user: user, bookstore: bookstore, book: book, date: myStringDate, status: false, type: preferenceTextField.text ?? "", additionalInfo: self.additionalinfoTextView.text ?? "")
        
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let instaniatedNavVC = storyBoard.instantiateViewController(withIdentifier: "ChatNavVC") as? UINavigationController
        
        let safeEmail = FirebaseManager.safeEmail(email: email)
        FirebaseManager.shared.getAllConversations(for: safeEmail, completion: { res in
            switch res {
            case .success(let convs):
                let navVc = instaniatedNavVC
                let vc = navVc?.topViewController as! ChatsViewController
                vc.application = application
                vc.conversations = convs
                UIApplication.shared.keyWindow?.rootViewController = navVc
            case .failure(let error):
                print(error)
            }
        })
    }
    
    @IBAction func sendApplicationAndDismiss(_ sender: Any) {
        guard let bookstore = appDelegate().currentReviewingOwnersProfile else { print("bookstore data empty")
            return }
        guard let book = book else { print("book data empty")
            return }
        guard let user = appDelegate().currentUser else { print("book data empty")
            return }
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        // again convert your date to string
        let myStringDate = formatter.string(from: yourDate!)
        
        let application = Application(userInfo: usersInfoTextView.text, user: user, bookstore: bookstore, book: book, date: myStringDate, status: false, type: preferenceTextField.text ?? "", additionalInfo: self.additionalinfoTextView.text ?? "")
        
        firestoreManager.sendApplication(email: bookstore.email ,application: application, completion: {[weak self]  success in
            if success {
                self?.dismiss(animated: true)
            } else {
                self?.showAlert(message: "Error")
            }
        })
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapPickPreferences(_ sender: UIButton) {
        rolesPicker = UIPickerView.init()
        rolesPicker.delegate = self
        rolesPicker.dataSource = self
        rolesPicker.backgroundColor = UIColor.white
        rolesPicker.autoresizingMask = .flexibleWidth
        rolesPicker.contentMode = .center
        rolesPicker.frame = CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 300)
        self.view.addSubview(rolesPicker)
        toolBar = UIToolbar.init(frame: CGRect.init(x: 0.0, y: UIScreen.main.bounds.size.height - 300, width: UIScreen.main.bounds.size.width, height: 50))
        toolBar.items = [UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(onDoneButtonTapped))]
        self.view.addSubview(toolBar)
        rolesPicker.selectRow(selectedIndex, inComponent: 0, animated: true)
    }
    
    @objc func onDoneButtonTapped() {
        toolBar.removeFromSuperview()
        rolesPicker.removeFromSuperview()
    }
    
    // MARK: UIPickerViewDelegate and UIPickerViewDataSource functions
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        preferences.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        preferences[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedIndex = row
        preferenceTextField.text = preferences[row]
    }
}
