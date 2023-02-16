//
//  BooksPresenter.swift
//  OnlineLibrary
//
//  Created by iosdev on 12.01.2023.
//

import UIKit
import FirebaseFirestore

class BooksPresenter {
    // MARK: Collection View
    
    /// Returns the number of sections in the dataSource
    var numberOfSections: Int {
        return 3
    }
    
    /// Returns the number of items for the given section
    func numberOfItems(for sectionIndex: Int, dataSource: [Section]) -> Int {
        let section = dataSource[sectionIndex]
        return section.data.count
    }
    
    // MARK: Cells
    
    /// Configures the given item with the app appropriate for the given IndexPath
    func configure(item: BookConfigurable, for indexPath: IndexPath, dataSource: [Section]) {
        let section = dataSource[indexPath.section]
        let book = section.data[indexPath.row]
        item.configure(with: book)
    }
    
    /// Returns the SectionType for the given sectionIndex
    func sectionType(for sectionIndex: Int, dataSource: [Section]) -> SectionType {
        let section = dataSource[sectionIndex]
        return section.type
    }
    
    // MARK: Supplementary Views
    
    /// Returns the title for the given sectionIndex
    func title(for sectionIndex: Int, dataSource: [Section]) -> String? {
        let section = dataSource[sectionIndex]
        return section.title
    }
    
    /// Returns the subtitle for the given sectionIndex
    func subtitle(for sectionIndex: Int, dataSource: [Section]) -> String? {
        let section = dataSource[sectionIndex]
        return section.subtitle
    }
}
