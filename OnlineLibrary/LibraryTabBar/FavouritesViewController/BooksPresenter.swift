//
//  BooksPresenter.swift
//  OnlineLibrary
//
//  Created by iosdev on 12.01.2023.
//

import UIKit

class BooksPresenter {
    
    private var dataSource: [Section] = []
    
    // We will initialise the dataSource in the init method.
    init() {
        // First section: Recomended
        let recommendedBooks = [Book(id: 1, type: "type1", name: "name1", subTitle: "subtitle1"),
                                Book(id: 2, type: "type2", name: "name2", subTitle: "subtitle2"),
                                Book(id: 3, type: "type3", name: "name3", subTitle: "subtitle3")]
        let section1 = Section(id: 1, type: .singleList, title: "Recommended", subtitle: "Recommended books by owner", data: recommendedBooks)
        
        dataSource.append(section1)
        
        // Second section: This weeks favorites
        let randomBooks = [Book(id: 4, type: "type4", name: "name4", subTitle: "subtitle4"),
                           Book(id: 5, type: "type5", name: "name5", subTitle: "subtitle5"),
                           Book(id: 6, type: "type6", name: "name6", subTitle: "subtitle6")]
        let section2 = Section(id: 2, type: .doubleList, title: "Random genre", subtitle: "Some books of random genre that changes every day", data: randomBooks)
        
        dataSource.append(section2)
        
        // Third section: Learn something
        let unknownBooks = [Book(id: 7, type: "type7", name: "name7", subTitle: "subtitle7"),
                            Book(id: 8, type: "type8", name: "name8", subTitle: "subtitle8"),
                            Book(id: 9, type: "type9", name: "name9", subTitle: "subtitle9"),
                            Book(id: 10, type: "type10", name: "name10", subTitle: "subtitle10"),
                            Book(id: 11, type: "type11", name: "name11", subTitle: "subtitle11"),
                            Book(id: 12, type: "type12", name: "name12", subTitle: "subtitle12")]
        let section3 = Section(id: 3, type: .tripleList, title: "Recently added", subtitle: "Last added books by owner", data: unknownBooks)
        
        
        dataSource.append(section3)
        
    }
    
    // MARK: Collection View
    
    /// Returns the number of sections in the dataSource
    var numberOfSections: Int {
        return dataSource.count
    }
    
    /// Returns the number of items for the given section
    func numberOfItems(for sectionIndex: Int) -> Int {
        let section = dataSource[sectionIndex]
        return section.data.count
    }
    
    // MARK: Cells
    
    /// Configures the given item with the app appropriate for the given IndexPath
    func configure(item: BookConfigurable, for indexPath: IndexPath) {
        let section = dataSource[indexPath.section]
        if let book = section.data[indexPath.row] as? Book {
            item.configure(with: book)
        } else {
            print("Error getting app for indexPath: \(indexPath)")
        }
    }
    
    /// Returns the SectionType for the given sectionIndex
    func sectionType(for sectionIndex: Int) -> SectionType {
        let section = dataSource[sectionIndex]
        return section.type
    }
    
    // MARK: Supplementary Views
    
    /// Returns the title for the given sectionIndex
    func title(for sectionIndex: Int) -> String? {
        let section = dataSource[sectionIndex]
        return section.title
    }
    
    /// Returns the subtitle for the given sectionIndex
    func subtitle(for sectionIndex: Int) -> String? {
        let section = dataSource[sectionIndex]
        return section.subtitle
    }
}
