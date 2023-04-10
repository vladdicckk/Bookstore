//
//  Models.swift
//  OnlineLibrary
//
//  Created by iosdev on 28.01.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import FirebaseFirestoreSwift

struct BookInfo: Codable, Equatable {
    var title: String
    var author: String
    var publishYear: Int
    var genre: String
    var pagesCount: Int
    var language: String
    var price: Double
    var additionalInfo: String
    var addingDate: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case author
        case publishYear
        case genre
        case pagesCount
        case language
        case price
        case additionalInfo
        case addingDate
    }
}

struct User: Codable {
    var firstName: String
    var lastName: String
    var age: Int
    var password: String
    var email: String
    var username: String
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

struct Bookstore: Codable {
    var name: String
    var ownersName: String
    var password: String
    var preference: String
    var phoneNumber: String
    var email: String
    var location: String
    var additionalInfo: String
    var books: [BookInfo]
    
    enum CodingKeys: String, CodingKey {
        case name
        case ownersName
        case password
        case preference
        case phoneNumber
        case email
        case location
        case additionalInfo
        case books
    }
}

struct Application: Codable {
    var userInfo: String
    var user: User
    var bookstore: Bookstore
    var book: BookInfo
    var date: String
    var status: Bool
    var type: String
    var additionalInfo: String
    
    enum CodingKeys: String, CodingKey {
        case userInfo
        case user
        case bookstore
        case date
        case status
        case type
        case book
        case additionalInfo
    }
}

struct ApplicationMainInfo: Codable {
    var userInfo: String
    var book: BookInfo
    var date: String
    var status: Bool
    var type: String
    var additionalInfo: String
    var bookstoreName: String
    var userEmail: String
    var bookstoreEmail: String
    
    enum CodingKeys: String, CodingKey {
        case userInfo
        case date
        case status
        case type
        case book
        case additionalInfo
        case bookstoreName
        case userEmail
        case bookstoreEmail
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.age == rhs.age &&
        lhs.email == rhs.email &&
        lhs.username == rhs.username &&
        lhs.location == rhs.location &&
        lhs.phoneNumber == rhs.phoneNumber
    }
}

extension Bookstore: Equatable {
    static func == (lhs: Bookstore, rhs: Bookstore) -> Bool {
        return lhs.name == rhs.name &&
        lhs.location == rhs.location &&
        lhs.ownersName == rhs.ownersName &&
        lhs.email == rhs.email &&
        lhs.preference == rhs.preference &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.additionalInfo == rhs.additionalInfo
    }
}
