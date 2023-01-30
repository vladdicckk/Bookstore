//
//  Validation.swift
//  OnlineLibrary
//
//  Created by iosdev on 29.01.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift


class Validation {
    let db = Firestore.firestore()
    var isUserNameUnique = false
    var isUserEmailUnique = false
    
    
    
    func isPhoneNumber(phone: String?) -> Bool {
        guard let phone = phone else { return false }
        /* The numbers 10, 12, 13 are the number of characters when entering a phone number.
         10 - Phone number without "+" and country code.
         12 - Phone number without "+".
         13 - Phone number with "+" and country code.
         */
        return phone.count == 10 || phone.count == 12 || phone.count == 13
    }
    
    func isEmail(enteredEmail: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
        
    }
}
