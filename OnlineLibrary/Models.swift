//
//  Models.swift
//  OnlineLibrary
//
//  Created by iosdev on 28.01.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseFirestoreSwift

struct BookInfo: Codable {
    var title: String
    var author: String
    var publishYear: Int
    var genre: String
    var pagesCount: Int
    var language: String
    var price: Int
    var additionalInfo: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case publishYear
        case genre
        case pagesCount
        case language
        case price
        case additionalInfo
    }
}

public struct User: Codable {
    var firstName: String
    var lastName: String
    var age: Int
    var password: String
    var email: String
    @DocumentID var username = "Username :"
    var phoneNumber: String
    var location: String
    
    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case age
        case password
        case email
        case username
        case phoneNumber
        case location
    }
}

struct Owner: Codable {
    var name: String
    var password: String
    var tradingType: String
    var phoneNumber: String
    var email: String
    var location: String
    var books: [BookInfo]
    
    enum CodingKeys: String, CodingKey {
        case name
        case password
        case tradingType
        case phoneNumber
        case email
        case location
        case books
    }
}
