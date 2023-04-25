//
//  RecomendedBooksCollectionViewCell.swift
//  OnlineLibrary
//
//  Created by iosdev on 12.01.2023.
//

import UIKit

class RecomendedBooksCollectionViewCell: UICollectionViewCell, BookConfigurable {
    // MARK: Properties
    let nameLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    // MARK: Private and public functions
    private func setup() {
        backgroundView = cellContentViewBackgroundBlur(cell: self, radius: 16)
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBrown.cgColor
        layer.cornerRadius = 17
        
        let separator = UIView(frame: .zero)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .quaternaryLabel
        
        let stackView = UIStackView(arrangedSubviews: [separator, nameLabel,
                                                       subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        stackView.setCustomSpacing(10, after: separator)
        stackView.setCustomSpacing(10, after: subtitleLabel)
        
        style()
    }
    
    private func style() {
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        subtitleLabel.textColor = .black
        nameLabel.textColor = .black
    }
    
    func configure(with book: BookInfo) {
        nameLabel.text = book.title
        subtitleLabel.text = book.author
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




