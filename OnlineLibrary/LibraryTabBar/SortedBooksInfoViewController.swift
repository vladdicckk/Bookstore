//
//  SortedBooksInfoViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class SortedBooksInfoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Properties
    var sortedBooksBy: [String] = ["Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book ", "Book "]
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        view.backgroundColor = UIColor(patternImage: UIImage(named: "librariesBackground")!)
        collectionView.backgroundColor = .clear
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sortedBooksBy.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SortedBooksCollectionViewCell", for: indexPath) as! SortedBooksCollectionViewCell
        cell.backgroundView = cell.cellContentViewBackgroundBlur(cell: cell, radius: 5)
        cell.configure(with: sortedBooksBy, indexPath: indexPath)
        cell.setup()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bookInfoViewVC: BookInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "BookInfoViewController") as! BookInfoViewController
        present(bookInfoViewVC, animated: true)
    }
}
