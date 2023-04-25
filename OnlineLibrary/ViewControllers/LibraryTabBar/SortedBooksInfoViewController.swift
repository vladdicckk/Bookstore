//
//  SortedBooksInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit
import FirebaseFirestore

protocol RecommendedBooksArr {
    func setRecommendedBooks(arr: [BookInfo])
}

class SortedBooksInfoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    // MARK: Outlets
    @IBOutlet weak var saveRecommendedBooksButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addBookButton: UIBarButtonItem!
    
    // MARK: Properties
    let db = Firestore.firestore()
    let firestoreManager = FirestoreManager()
    var isAppendingRecommended: Bool? = false
    var books: [BookInfo]?
    var booksTemp: [BookInfo]?
    var recommendedBooksArr: [BookInfo] = []
    var prefillRecBooksArr: [BookInfo]?
    var delegate: RecommendedBooksArr?
    var searchBar: UISearchBar = UISearchBar()
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        booksTemp = books
        collectionView.dataSource = self
        collectionView.delegate = self
        setSearchBar()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        
        if !(isAppendingRecommended ?? false) {
            saveRecommendedBooksButton.isHidden = true
        }
        
        if appDelegate().currentBookstoreOwner == nil {
            if #available(iOS 16.0, *) {
                addBookButton.isHidden = true
            } else {
                // Fallback on earlier versions
                addBookButton.isEnabled = false
            }
        }
        
        if appDelegate().currentBookstoreOwner != nil && appDelegate().currentReviewingOwnersProfile != nil {
            if #available(iOS 16.0, *) {
                addBookButton.isHidden = true
            } else {
                // Fallback on earlier versions
                addBookButton.isEnabled = false
            }
        }
        view.backgroundColor = UIColor(patternImage: UIImage(named: "librariesBackground")!)
        collectionView.backgroundColor = .clear
        //Looks for single or multiple taps.
        let tap = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        searchBar.resignFirstResponder()
    }
    
    private func showAlert(point: CGPoint) {
        let alert = UIAlertController(title: "Are you sure?", message: "This book will be deleted from your bookstore", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction) in
            let indexPath = self.collectionView!.indexPathForItem(at: point)
            guard let row = indexPath?.row else {
                print("row nil")
                return }
            
            guard let indexPath = indexPath else {
                print("indexPath nil")
                return }
            
            guard let book = self.books?[row] else { return
                print("error")
            }
            
            guard let email = self.appDelegate().currentBookstoreOwner?.email else { return }
            self.firestoreManager.deleteBookFromDB(email: email, bookInfo: book)
            self.books?.remove(at: row)
            self.collectionView.deleteItems(at: [indexPath])
        }))
        
        let actionNo = UIAlertAction(title: "No", style: .default)
        
        alert.addAction(actionNo)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func deleteBookInfo(sender: UIButton!) {
        let point: CGPoint = sender.convert(CGPointZero, to: collectionView)
        showAlert(point: point)
    }
    
    private func setSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.placeholder = "Find your books by title"
        
        navigationItem.titleView = searchBar
        
        if books?.count == 0 {
            searchBar.isHidden = true
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let email = appDelegate().currentBookstoreOwner?.email else { return }
        self.delegate?.setRecommendedBooks(arr: self.recommendedBooksArr)
        firestoreManager.deleteDeselectedBooksFromRecommended(email: email, recommendedBooksArr: self.recommendedBooksArr)
        firestoreManager.setRecommendedBooks(recommendedBooksArr: self.recommendedBooksArr, email: email)
        
        dismiss(animated: true)
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        books?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SortedBooksCollectionViewCell", for: indexPath) as! SortedBooksCollectionViewCell
        guard let books = books else { return cell }
        collectionView.backgroundColor = .clear
        
        cell.backgroundView = cell.cellContentViewBackgroundBlur(cell: cell, radius: 5)
        cell.configure(with: books[indexPath.row].title, author: books[indexPath.row].author, genre: books[indexPath.row].genre, publishYear: books[indexPath.row].publishYear)
        cell.setup(collectionViewWidth: collectionView.width)
        cell.deleteButton.addTarget(self, action: #selector(deleteBookInfo), for: .touchUpInside)
        if appDelegate().currentBookstoreOwner == nil || isAppendingRecommended == true {
            if #available(iOS 16.0, *) {
                cell.deleteButton.isHidden = true
            } else {
                // Fallback on earlier versions
                cell.deleteButton.isEnabled = false
            }
        }
        if appDelegate().currentBookstoreOwner != nil && appDelegate().currentReviewingOwnersProfile != nil {
            if #available(iOS 16.0, *) {
                cell.deleteButton.isHidden = true
            } else {
                // Fallback on earlier versions
                cell.deleteButton.isEnabled = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let isAppendingRecommended = isAppendingRecommended else { return }
        guard let books = books else { return }
        if isAppendingRecommended {
            let cell = collectionView.cellForItem(at: indexPath)
            if cell?.layer.borderWidth == 5.0 || cell?.layer.borderColor == UIColor.red.cgColor {
                cell?.layer.borderWidth = 2
                cell?.layer.borderColor = UIColor.systemBrown.cgColor
            } else {
                
                cell?.layer.borderWidth = 5.0
                cell?.layer.borderColor = UIColor.red.cgColor
            }
            if !recommendedBooksArr.contains(books[indexPath.row]) {
                recommendedBooksArr.append(books[indexPath.row])
            } else {
                if indexPath.row == 0 {
                    recommendedBooksArr.remove(at: indexPath.row)
                } else {
                    recommendedBooksArr.remove(at: indexPath.row - 1)
                }
            }
        } else {
            let bookInfoViewVC: BookInfoViewController = storyboard?.instantiateViewController(withIdentifier: "BookInfoViewController") as! BookInfoViewController
            bookInfoViewVC.bookTitle = books[indexPath.row].title
            bookInfoViewVC.author = books[indexPath.row].author
            bookInfoViewVC.publishYear = books[indexPath.row].publishYear
            bookInfoViewVC.language = books[indexPath.row].language
            bookInfoViewVC.pagesCount = books[indexPath.row].pagesCount
            bookInfoViewVC.additionalInfo = books[indexPath.row].additionalInfo
            bookInfoViewVC.genre = books[indexPath.row].genre
            bookInfoViewVC.price = books[indexPath.row].price
            
            bookInfoViewVC.modalPresentationStyle = .overFullScreen
            present(bookInfoViewVC, animated: true)
        }
    }
    
    // MARK: UISearchBarDelegate functions
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        books = []
        
        for book in booksTemp! {
            if book.title.lowercased().contains(searchBar.text?.lowercased() ?? "") {
                books!.append(book)
            }
        }
        self.collectionView.reloadData()
        
        if searchText == "" {
            books = booksTemp
            self.collectionView.reloadData()
        }
    }
}
