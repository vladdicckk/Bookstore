//
//  TypesOfBookSortingViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit
import FirebaseFirestore

class TypesOfBookSortingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var sortTypes: [String] = ["Alphabet", "Genre", "Authors", "The newest", "The oldest"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BooksTypeCell")
        mainViewProperties()
    }
    
    func mainViewProperties() {
        greetingViewProperties()
        tableViewProperties()
    }
    
    func greetingViewProperties() {
        greetingView.setCorner(radius: 16)
        greetingView.layer.borderWidth = 1
        greetingView.layer.borderColor = UIColor.brown.cgColor
    }
    
    func tableViewProperties() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.75
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        tableView.backgroundColor = .clear
        tableView.backgroundView = backgroundBlur
        
        backgroundBlur.frame = tableView.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooksTypeCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.textProperties.font = .boldSystemFont(ofSize: 18)
        content.text = sortTypes[indexPath.row]
        guard let tabBar = tabBarController?.tabBar else { return cell }
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: cell.height * 5),
            tableView.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
        
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
        let email = appDelegate().currentReviewingOwnersProfile?.email
        let currentBookstoreOwnerEmail = appDelegate().currentBookstoreOwner?.email
        let sortedBooksVC: SortedBooksInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "SortedBooksInfoViewController") as! SortedBooksInfoViewController
        
        if indexPath.row == 0 {
            firestoreManager.getBooks(email: email ?? currentBookstoreOwnerEmail ?? "", completion: { booksArr in
                if booksArr.count > 1 {
                    var sortedBooksArr: [BookInfo] = []
                    sortedBooksArr = booksArr.sorted { $0.title.lowercased() < $1.title.lowercased() }
                    sortedBooksVC.books = sortedBooksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                } else {
                    sortedBooksVC.books = booksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                }
            })
        } else if indexPath.row == 1 {
            firestoreManager.getBooks(email: email ?? currentBookstoreOwnerEmail ?? "", completion: { booksArr in
                if booksArr.count > 1 {
                    var sortedBooksArr: [BookInfo] = []
                    sortedBooksArr = booksArr.sorted { $0.genre.lowercased() < $1.genre.lowercased() }
                    sortedBooksVC.books = sortedBooksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                } else {
                    sortedBooksVC.books = booksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                }
            })
        } else if indexPath.row == 2 {
            firestoreManager.getBooks(email: email ?? currentBookstoreOwnerEmail ?? "", completion: { booksArr in
                if booksArr.count > 1 {
                    var sortedBooksArr: [BookInfo] = []
                    sortedBooksArr = booksArr.sorted { $0.author.lowercased() < $1.author.lowercased() }
                    sortedBooksVC.books = sortedBooksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                } else {
                    sortedBooksVC.books = booksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                }
            })
        } else if indexPath.row == 3 {
            firestoreManager.getBooks(email: email ?? currentBookstoreOwnerEmail ?? "", completion: { booksArr in
                if booksArr.count > 1 {
                    var sortedBooksArr: [BookInfo] = []
                    sortedBooksArr = booksArr.sorted { $0.publishYear > $1.publishYear }
                    sortedBooksVC.books = sortedBooksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                } else {
                    sortedBooksVC.books = booksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                }
            })
        } else {
            firestoreManager.getBooks(email: email ?? currentBookstoreOwnerEmail ?? "", completion: { booksArr in
                if booksArr.count > 1 {
                    var sortedBooksArr: [BookInfo] = []
                    sortedBooksArr = booksArr.sorted { $0.publishYear < $1.publishYear }
                    sortedBooksVC.books = sortedBooksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                } else {
                    sortedBooksVC.books = booksArr
                    self.navigationController?.pushViewController(sortedBooksVC, animated: true)
                }
            })
        }
    }
}
