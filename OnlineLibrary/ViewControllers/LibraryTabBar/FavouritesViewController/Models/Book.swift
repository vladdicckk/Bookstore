//
//  Book.swift
//  OnlineLibrary
//
//  Created by iosdev on 12.01.2023.
//

import Foundation

protocol SectionData { }

// Descibes the info needed for a Section
struct Book: SectionData {
    let id: Int
    let type: String
    let name: String
    let subTitle: String
}
