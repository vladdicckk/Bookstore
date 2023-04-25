//
//  SortedBooksCollectionViewCell.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.01.2023.
//

import UIKit

class SortedBooksCollectionViewCell: UICollectionViewCell {
    // MARK: Outlets
    @IBOutlet weak var bookTitle: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var publishYearLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: Public functions
    func setup(collectionViewWidth: CGFloat) {
        
        backgroundView = cellContentViewBackgroundBlur(cell: self, radius: 16)
        
        layer.cornerRadius = 16
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBrown.cgColor
        
        let stackView = UIStackView(arrangedSubviews: [bookTitle, authorLabel, genreLabel, publishYearLabel, deleteButton])
        stackView.axis = .vertical
        bookTitle.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        publishYearLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        bookTitle.font = .boldSystemFont(ofSize: 15)
        authorLabel.font = .boldSystemFont(ofSize: 15)
        genreLabel.font = .boldSystemFont(ofSize: 15)
        publishYearLabel.font = .boldSystemFont(ofSize: 15)
        
        bookTitle.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        authorLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        genreLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        publishYearLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.configuration = .tinted()
        
        
        contentView.addSubview(stackView)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: collectionViewWidth - 20),
            contentView.heightAnchor.constraint(equalToConstant: bookTitle.height*3),
            
            bookTitle.heightAnchor.constraint(equalToConstant: 21),
            authorLabel.heightAnchor.constraint(equalToConstant: 21),
            genreLabel.heightAnchor.constraint(equalToConstant: 21),
            publishYearLabel.heightAnchor.constraint(equalToConstant: 21),

            deleteButton.heightAnchor.constraint(equalToConstant: contentView.height),
            deleteButton.widthAnchor.constraint(equalToConstant: contentView.height/4),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            bookTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            bookTitle.bottomAnchor.constraint(equalTo: authorLabel.topAnchor),
            authorLabel.bottomAnchor.constraint(equalTo: genreLabel.topAnchor),
            genreLabel.bottomAnchor.constraint(equalTo: publishYearLabel.topAnchor, constant: 0),
            publishYearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            bookTitle.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: 0),
            publishYearLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: 0),
            
            stackView.widthAnchor.constraint(equalToConstant: contentView.width),
            stackView.heightAnchor.constraint(equalToConstant: contentView.height),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10)
        ])
    }
    
    func configure(with title: String, author: String, genre: String, publishYear: Int) {
        bookTitle.text = "Book title: \(title)"
        authorLabel.text = "Author: \(author)"
        genreLabel.text = "Genre: \(genre)"
        publishYearLabel.text = "Publish year: \(publishYear)"
    }
}
