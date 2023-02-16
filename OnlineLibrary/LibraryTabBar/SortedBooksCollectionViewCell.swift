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
    
    var deleteButton: UIButton = UIButton()
    
    // MARK: Public functions
    func setup() {
        backgroundView = cellContentViewBackgroundBlur(cell: self, radius: 0)
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBrown.cgColor
        
        let stackView = UIStackView(arrangedSubviews: [bookTitle, authorLabel, genreLabel, publishYearLabel])
        stackView.axis = .vertical
        bookTitle.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        genreLabel.translatesAutoresizingMaskIntoConstraints = false
        publishYearLabel.translatesAutoresizingMaskIntoConstraints = false
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        bookTitle.font = .boldSystemFont(ofSize: 15)
        authorLabel.font = .boldSystemFont(ofSize: 15)
        genreLabel.font = .boldSystemFont(ofSize: 15)
        publishYearLabel.font = .boldSystemFont(ofSize: 17)
        bookTitle.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        authorLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        genreLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        publishYearLabel.textColor = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .red
        deleteButton.configuration = .tinted()
        
        
        contentView.addSubview(stackView)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            
            bookTitle.heightAnchor.constraint(equalToConstant: 30),
            authorLabel.heightAnchor.constraint(equalToConstant: 30),
            genreLabel.heightAnchor.constraint(equalToConstant: 30),
            publishYearLabel.heightAnchor.constraint(equalToConstant: 30),
            bookTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            
            deleteButton.heightAnchor.constraint(equalToConstant: 125),
            deleteButton.widthAnchor.constraint(equalToConstant: 60),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            bookTitle.bottomAnchor.constraint(equalTo: authorLabel.topAnchor, constant: 5),
            authorLabel.bottomAnchor.constraint(equalTo: genreLabel.topAnchor, constant: 5),
            genreLabel.bottomAnchor.constraint(equalTo: publishYearLabel.topAnchor, constant: 5),
            publishYearLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 5),
            
            stackView.widthAnchor.constraint(equalToConstant: 350),
            stackView.heightAnchor.constraint(equalToConstant: 120),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 30),
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
