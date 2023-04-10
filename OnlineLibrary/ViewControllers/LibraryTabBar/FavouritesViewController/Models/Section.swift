//
//  Section.swift
//  OnlineLibrary
//
//  Created by iosdev on 12.01.2023.
//

import UIKit

enum SectionType: Int, CaseIterable {
    case singleList     // Featured
    case doubleList     // This weeks favorites
    case tripleList     // Learn something
}

// Descibes the info needed for a Section
struct Section {
    let id: Int
    let type: SectionType
    let title: String?
    let subtitle: String?
    let data: [BookInfo]
}
