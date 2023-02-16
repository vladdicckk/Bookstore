//
//  LibrariesViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit
import FirebaseFirestore


class LibrariesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SortByResultTypeProtocol, UISearchBarDelegate {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var mainLibrariesView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    // MARK: Parameters
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var bookStoreTitles: [String]?
    var bookStoreTitlesTemp: [String]?
    var button: UIBarButtonItem = UIBarButtonItem()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LibraryCell")
        tableView.backgroundColor = .clear
        mainLibrariesViewSettings()
        self.navigationController?.isNavigationBarHidden = false
        
        for view in searchBar.subviews.last!.subviews {
            if type(of: view) == NSClassFromString("UISearchBarBackground"){
                view.alpha = 0.0
            }
        }
    }
    
    // MARK: Private functions
    private func mainLibrariesViewSettings() {
        mainLibrariesView.backgroundColor = .clear
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.5
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        mainLibrariesView.backgroundColor = UIColor(patternImage: UIImage(named: "librariesBackground")!)
        mainLibrariesView.addSubview(backgroundBlur)
        mainLibrariesView.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundBlurConstraints(blur: backgroundBlur)
    }
    
    private func backgroundBlurConstraints(blur: UIVisualEffectView) {
        blur.topAnchor.constraint(equalTo: mainLibrariesView.topAnchor, constant: 0).isActive = true
        blur.leadingAnchor.constraint(equalTo: mainLibrariesView.leadingAnchor, constant: 0).isActive = true
        blur.trailingAnchor.constraint(equalTo: mainLibrariesView.trailingAnchor, constant: 0).isActive = true
        blur.bottomAnchor.constraint(equalTo: mainLibrariesView.bottomAnchor, constant: 0).isActive = true
    }
    
    
    func sortNamesBy(type: String, location: String, preference: String) {
        if type == "Sort by alphabet" {
            bookStoreTitles = bookStoreTitlesTemp?.sorted { (lhs: String, rhs: String) -> Bool in
                return lhs.compare(rhs, options: .caseInsensitive) == .orderedAscending
            }
            tableView.reloadData()
        } else if type == "Filter by location" {
            firestoreManager.getBookstoresWithChoosedLocation(location: location, { success, arr in
                if success {
                    self.bookStoreTitles = arr
                    self.tableView.reloadData()
                } else {
                    print("Error")
                }
            })
        } else if type == "Filter by preference" {
            firestoreManager.getBookstoresWithChoosedPreference(preference: preference, { success, arr in
                if success {
                    self.bookStoreTitles = arr
                    self.tableView.reloadData()
                } else {
                    print("Error")
                }
            })
        }
    }
    
    // MARK: Actions
    @IBAction func filterButtonTapped(_ sender: Any) {
        let filterVC: FilterByViewController = storyboard?.instantiateViewController(withIdentifier: "FilterByViewController") as! FilterByViewController
        filterVC.delegate = self
        present(filterVC, animated: true)
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookStoreTitles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
        guard let bookStoreTitles = bookStoreTitles else { return cell }
        var content = cell.defaultContentConfiguration()
        
        content.textProperties.font = .boldSystemFont(ofSize: 22)
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.text = bookStoreTitles[indexPath.row]
        
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 1
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        cell.backgroundView = backgroundBlur
        cell.selectedBackgroundView = cell.backgroundView
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.selectedBackgroundView?.layer.cornerRadius = 16
        cell.layer.cornerRadius = 16
        cell.backgroundColor = .clear
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let bookStoreTitles = bookStoreTitles else { return }
        let tabBC: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
        let nav = tabBC.viewControllers?[0] as! UINavigationController
        let nav_2 = tabBC.viewControllers?[2] as! UINavigationController
        
        let bookstoreProfileVC = nav.topViewController as! LibraryViewController
        let favouritesVC = nav_2.topViewController as! FavouritesViewController
        firestoreManager.getBookstoreData(name: bookStoreTitles[indexPath.row], completion: { bookstore in
            self.appDelegate().currentReviewingOwnersProfile = bookstore
            
            self.firestoreManager.getRecommendedBooks(email: bookstore.email, completion: { arr in
                self.firestoreManager.configureRandomBooksOfRandomGenre(email: bookstore.email, completion: { randArr in
                    self.firestoreManager.configureRecentlyAddedBooks(email: bookstore.email, completion: { recentArr in
                        favouritesVC.recommendedBooksArr = arr
                        favouritesVC.randomBooksArr = randArr
                        favouritesVC.recentlyAddedBooksArr = recentArr
                        
                        bookstoreProfileVC.bookstoreName = bookstore.name
                        bookstoreProfileVC.email = bookstore.email
                        bookstoreProfileVC.preference = bookstore.preference
                        bookstoreProfileVC.phoneNumber = bookstore.phoneNumber
                        bookstoreProfileVC.address = bookstore.location
                        bookstoreProfileVC.bookstoreOwnersName = bookstore.ownersName
                        bookstoreProfileVC.additionalInfoText = bookstore.additionalInfo
                        
                        UIApplication.shared.keyWindow?.rootViewController = tabBC
                    })
                })
            })
        })
    }
    
    // MARK: UISearchBarDelegate functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let bookStoreTitlesTemp = bookStoreTitlesTemp else { return }
        bookStoreTitles?.removeAll()
        
        for bookstore in bookStoreTitlesTemp {
            if bookstore.lowercased().contains(searchBar.text?.lowercased() ?? "") {
                bookStoreTitles?.append(bookstore)
            }
            
        }
        self.tableView.reloadData()
        
        if searchText == "" {
            bookStoreTitles = bookStoreTitlesTemp
            self.tableView.reloadData()
        }
    }
}

