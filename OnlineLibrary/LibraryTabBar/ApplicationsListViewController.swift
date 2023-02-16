//
//  ApplicationsListViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 13.02.2023.
//

import UIKit
import FirebaseFirestore

class ApplicationsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // MARK: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    var applicationsArr: [ApplicationMainInfo]?
    var applicationsArrTemp: [ApplicationMainInfo]?
    var firestoreManager = FirestoreManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProperties()
        searchBarProperties()
        applicationsArrTemp = applicationsArr
        view.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Applications"
    }
    
    private func searchBarProperties() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.placeholder = "Find applications by book title"
        for view in searchBar.subviews.last!.subviews {
            if type(of: view) == NSClassFromString("UISearchBarBackground"){
                view.alpha = 0.0
                view.backgroundColor = .clear
            }
        
        }
        searchBar.addSubview(backgroundBlur)
        searchBar.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        searchBar.layer.cornerRadius = 15


        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0),
            backgroundBlur.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0),
            backgroundBlur.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 0),
            backgroundBlur.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0)
        ])
        searchBar.backgroundColor = .clear
        
    }
    
    private func tableViewProperties() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ApplicaitonCell")
        tableView.backgroundColor = .clear
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        tableView.backgroundView = backgroundBlur
    }
    
    // MARK: UITableViewDelegate and UITableViewDataSource funcitons
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        applicationsArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplicaitonCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = .boldSystemFont(ofSize: 22)
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        
        cell.backgroundView = backgroundBlur
        cell.selectedBackgroundView = cell.backgroundView
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.selectedBackgroundView?.layer.cornerRadius = 16
        cell.layer.cornerRadius = 16
        cell.backgroundColor = .clear
        
        content.text = "Title: \(applicationsArr?[indexPath.row].book.title ?? "") Author: \(applicationsArr?[indexPath.row].book.author ?? "")"
        if applicationsArr?[indexPath.row].type != "" {
            content.secondaryText = "Type: \(applicationsArr?[indexPath.row].type ?? "")"
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let applicationsArr = applicationsArr else { return }
        let vc: ApplicationViewController = self.storyboard?.instantiateViewController(withIdentifier: "ApplicationViewController") as! ApplicationViewController
        vc.application = applicationsArr[indexPath.row]
        present(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let email = appDelegate().currentBookstoreOwner?.email else { return }
        if editingStyle == .delete {
            firestoreManager.deleteApplication(email: email, applicaton: (applicationsArr?[indexPath.row])!)
            self.applicationsArr?.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: UISearchBarDelegate functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applicationsArr = []
        
        for application in applicationsArrTemp! {
            if application.book.title.lowercased().contains(searchBar.text?.lowercased() ?? "") {
                applicationsArr!.append(application)
            }
        }
        self.tableView.reloadData()
        
        if searchText == "" {
            applicationsArr = applicationsArrTemp
            self.tableView.reloadData()
        }
    }
}
