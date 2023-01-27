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
    
    // MARK: Public functions
    func setup() {
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBrown.cgColor
        
        let stackView = UIStackView(arrangedSubviews: [bookTitle])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalToConstant: 350),
            stackView.heightAnchor.constraint(equalToConstant: 115),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with arr: [String], indexPath: IndexPath) {
        bookTitle.text = arr[indexPath.row] + "\(indexPath.row + 1)"
    }
}
