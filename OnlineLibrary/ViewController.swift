//
//  ViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit
import FirebaseFirestore

class ViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet var mainView: UIView!
    
    // MARK: Parameters
    let database = Firestore.firestore()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        greetingViewSettings()
    }
    
    // MARK: Private functions
    
    private func greetingViewSettings() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.75
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        greetingView.setCorner(radius: 18)
        greetingView.layer.borderWidth = 1
        greetingView.layer.borderColor = UIColor.black.cgColor
        greetingView.backgroundColor = .clear
        greetingView.addSubview(backgroundBlur)
        greetingView.sendSubviewToBack(backgroundBlur)
        
        backgroundBlurConstraints(blur: backgroundBlur)
    }
    
    private func backgroundBlurConstraints(blur: UIVisualEffectView) {
        blur.topAnchor.constraint(equalTo: greetingView.topAnchor, constant: 0).isActive = true
        blur.leadingAnchor.constraint(equalTo: greetingView.leadingAnchor, constant: 0).isActive = true
        blur.trailingAnchor.constraint(equalTo: greetingView.trailingAnchor, constant: 0).isActive = true
        blur.bottomAnchor.constraint(equalTo: greetingView.bottomAnchor, constant: 0).isActive = true
    }
    
    private func getData(completion: @escaping ([String]) -> ()) {
        database.collection("Owners").getDocuments() { (querySnapshot, err) in
            var arr: [String] = [""]
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                arr.removeAll()
                for document in querySnapshot!.documents {
                    arr.append(document.documentID)
                }
                completion(arr)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func signButtonTapped(_ sender: Any) {
        let signInViewController: SignInViewController = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    @IBAction func toLibrariesButtonTapped(_ sender: Any) {
        let vc: LibrariesViewController = self.storyboard?.instantiateViewController(withIdentifier: "LibrariesViewController") as! LibrariesViewController
        getData(completion: { arr in
            vc.bookStoreTitles = arr
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}



