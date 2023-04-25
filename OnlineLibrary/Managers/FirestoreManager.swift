//
//  FirestoreManager.swift
//  OnlineLibrary
//
//  Created by iosdev on 15.02.2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class FirestoreManager {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    func getBookstoreAvatarURL(email: String, completion: @escaping (_ avatar: URL) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            let avatarURL = "\(res?.get("AvatarImageURL") ?? "")"
            let url = URL(string: avatarURL)
            guard let url = url else { return }
            completion(url)
        })
    }
    
    func getUserAvatarURL(email: String, completion: @escaping (_ avatar: URL) -> Void) {
        db.collection("Users").document(email).getDocument(completion: { res, err in
            let avatarURL = "\(res?.get("AvatarImageURL") ?? "")"
            let url = URL(string: avatarURL)
            guard let url = url else { return }
            completion(url)
        })
    }
    
    func downloadUserAvatar(email: String, completion: @escaping (_ avatar: UIImage) -> Void) {
        if email != "" {
            db.collection("Users").document(email).getDocument(completion: { res, err in
                let avatarURL = "\(res?.get("AvatarImageURL") ?? "")"
                let url = URL(string: avatarURL)
                guard let url = url else { return }
                URLSession.shared.dataTask(with: url, completionHandler: { data, _ , err in
                    guard let data = data, err == nil else { return }
                    
                    let image = UIImage(data: data)
                    if let image = image {
                        print("\(image)")
                        completion(image)
                    } else {
                        print("error downloading image")
                    }
                }).resume()
            })
        }
    }
    
    func downloadBookstoreAvatar(email: String, completion: @escaping (_ avatar: UIImage) -> Void) {
        if email != "" {
            db.collection("Owners").document(email).getDocument(completion: { res, err in
                let avatarURL = "\(res?.get("AvatarImageURL") ?? "")"
                let url = URL(string: avatarURL)
                guard let url = url else { return }
                URLSession.shared.dataTask(with: url, completionHandler: { data, _ , err in
                    guard let data = data, err == nil else { return }
                    
                    let image = UIImage(data: data)
                    if let image = image {
                        print("\(image)")
                        completion(image)
                    } else {
                        print("error downloading image")
                    }
                }).resume()
            })
        }
    }
    
    func checkForBookstoreExisting(email: String, _ completion: @escaping (_ exists: Bool) -> Void) {
        let bookstores = db.collection("Owners")
        bookstores.document(email).getDocument { query, err in
            guard let existing = query?.exists else {
                return
            }
            if existing {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkForBookstoreNameExisting(bookstoreName: String, email: String, _ completion: @escaping (_ nameExists: Bool) -> Void) {
        let bookstores = db.collection("Owners")
        bookstores.document(email).getDocument { query, err in
            if query!.exists {
                self.getNamesData(completion: { arr in
                    for name in arr {
                        if name == "\(bookstoreName)" {
                            completion(true)
                        }
                    }
                    completion(false)
                })
            } else {
                completion(false)
            }
        }
    }
    
    func addBookstore(bookstore: Bookstore) {
        let bookstores = db.collection("Owners")
        do {
            try bookstores.document(bookstore.email).setData(from: bookstore)
        } catch let error {
            print ("Error: \(error)")
        }
    }
    
    func checkForUserExisting(email: String, _ completion: @escaping (_ exists: Bool) -> Void) {
        let users = db.collection("Users")
        guard email != "" else { return }
        users.document(email).getDocument { query, err in
            guard let data = query?.data(), let emailFromDB = data["email"] as? String, emailFromDB == email else {
                print("User doesn`t exist: \(err?.localizedDescription ?? "")")
                completion(false)
                return }
            completion(true)
        }
    }
    
    func checkForUsernameExisting(username: String, _ completion: @escaping (_ exists: Bool) -> Void) {
        let users = db.collection("Users")
        users.getDocuments { query, err in
            guard let data = query?.documents else {
                print("User doesn`t exist: \(err?.localizedDescription ?? "")")
                completion(false)
                return }
            var tempBoolean = false
            for user in data {
                if let usernameFromDB = user["username"] as? String {
                    if usernameFromDB == username {
                        tempBoolean = true
                    }
                }
            }
            
            if tempBoolean {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func addUser(user: User) {
        let users = db.collection("Users")
        do {
            try users.document(user.email).setData(from: user)
        } catch let error {
            print ("Error: \(error)")
        }
    }
    
    func getUserInfo(email: String, completion: @escaping (_ user: User) -> Void) {
        let users = db.collection("Users")
        if email != "" {
            users.document(email).getDocument(completion: { res, err in
                guard let data = res?.data() else {
                    print("User doesn`t exist: \(err?.localizedDescription ?? "")")
                    completion(User(firstName: "", lastName: "", age: 0, password: "", email: "", username: "", phoneNumber: "", location: ""))
                    return }
                
                let user = User(firstName: data["firstName"] as? String ?? "", lastName: data["lastName"] as? String ?? "", age: data["age"] as? Int ?? 0, password: "*", email: data["email"] as? String ?? "", username: data["username"] as? String ?? "", phoneNumber: data["phoneNumber"] as? String ?? "", location: data["location"] as? String ?? "")
                completion(user)
            })
        } else {
            print("Email is empty, failed getting user info")
        }
//        else {
//            users.whereField("username", isEqualTo: username).getDocuments(completion: { res, err in
//                guard let res = res?.documents else {
//                    print("User doesn`t exist")
//                    return }
//                for data in res {
//                    guard let usernameFromDB = data["username"] as? String, usernameFromDB == username else {
//                        print("error getting user from db")
//                        return }
//
//                    let user = User(firstName: data["firstName"] as? String ?? "", lastName: data["lastName"] as? String ?? "", age: data["age"] as? Int ?? 0, password: "*", email: data["email"] as? String ?? "", username: data["username"] as? String ?? "", phoneNumber: data["phoneNumber"] as? String ?? "", location: data["location"] as? String ?? "")
//                    completion(user)
//                }
//            })
//        }
    }
    
    func getBookstoreDataWithEmail(email: String, completion: @escaping (_ bookstore: Bookstore) -> Void) {
        let bookstores = db.collection("Owners")
        guard email != "" else {
            print("Email is empty, failed getting user info")
            return }
        
        bookstores.document(email).getDocument(completion: { res, err in
            guard let bookstore = res?.data() else {
                print("Bookstore doesn`t exist: \(err?.localizedDescription ?? "")")
                return }
            let books: [BookInfo] = bookstore["books"] as? [BookInfo] ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
            
            let bookStore = Bookstore(name: bookstore["name"] as? String ?? "", ownersName: bookstore["Owners name"] as? String ?? "Set owners name", password: "*", preference: bookstore["preference"] as? String ?? "", phoneNumber: bookstore["phoneNumber"] as? String ?? "" , email: bookstore["email"] as? String ?? "", location: bookstore["location"] as? String ?? "", additionalInfo: bookstore["additionalInfo"] as? String ?? "", books: books)
            completion(bookStore)
        })
    }
    
    func checkBookTitleForExisting(title: String, email: String, completion: @escaping(_ exists: Bool) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            guard let data = res?.data() else { return }
            var boolValue = false
            let booksArr = data["books"] as? [String: Any]
            if let dict = booksArr?[title] {
                let bookInfoArr = dict as! NSDictionary
                for item in bookInfoArr {
                    if "\(item.value)" == title {
                        boolValue = true
                        print("found title")
                        completion(true)
                    }
                }
                if boolValue == false {
                    completion(false)
                }
            } else {
                completion(false)
            }
        })
    }
    
    func checkBookAuthorForExisting(title: String, email: String, author: String, completion: @escaping(_ exists: Bool) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            guard let data = res?.data() else { return }
            var boolValue = false
            let booksArr = data["books"] as? [String: Any]
            if let dict = booksArr?[title] {
                let bookInfoArr = dict as! NSDictionary
                for item in bookInfoArr {
                    if "\(item.value)" == author {
                        boolValue = true
                        print("found author")
                        completion(true)
                    }
                }
                if boolValue == false {
                    completion(false)
                }
            } else {
                completion(false)
            }
        })
    }
    
    func addBook(email: String, title: String, author: String, publishYear: Int, genre: String, pagesCount: Int, language: String, price: Double, additionalInfo: String) {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let myString = formatter.string(from: Date()) // string purpose I add here
        // convert your string to date
        let yourDate = formatter.date(from: myString)
        //then again set the date format whhich type of output you need
        formatter.dateFormat = "dd-MMM-yyyy"
        // again convert your date to string
        let myStringDate = formatter.string(from: yourDate!)
        
        let doc = db.collection("Owners").document(email)
        doc.updateData([
            "books.\(title)": ["title" : title, "author" :  author, "publishYear" :  "\(publishYear)", "genre" :  genre, "pagesCount" :  "\(pagesCount)", "language" :  language, "price" :  "\(price)", "additionalInfo" :  additionalInfo, "addingDate" : myStringDate]
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully added")
            }
        }
    }
    
    func deleteDeselectedBooksFromRecommended(email: String, recommendedBooksArr: [BookInfo]) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var title = ""
            var author = ""
            var publishYear = ""
            var genre = ""
            var pagesCount = ""
            var language = ""
            var price = ""
            var additionalInfo = ""
            var addingDate = ""
            
            let booksFromDBTemp = res?.get("recommendedBooks")
            let checkCount_1 = booksFromDBTemp as? NSDictionary
            
            guard checkCount_1 != nil else {
                print("err")
                return
            }
            
            var booksFromDBArr: [BookInfo] = []
            let booksFromDB = booksFromDBTemp as! NSDictionary
            
            for info in booksFromDB {
                let infoValues = info.value as! NSDictionary
                for someInfoValue in infoValues {
                    if "\(someInfoValue.key)" == "title" {
                        title = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "author" {
                        author = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "publishYear" {
                        publishYear = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "genre" {
                        genre = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "pagesCount" {
                        pagesCount = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "language" {
                        language = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "price" {
                        price = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "additionalInfo" {
                        additionalInfo = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "addingDate" {
                        addingDate = "\(someInfoValue.value)"
                    }
                }
                
                let bookFromDB: BookInfo = BookInfo(title: title, author: author, publishYear: Int(publishYear) ?? 0, genre: genre, pagesCount: Int(pagesCount) ?? 0, language: language, price: Double(price) ?? 0.0, additionalInfo: additionalInfo, addingDate: addingDate)
                booksFromDBArr.append(bookFromDB)
            }
            
            for book in booksFromDBArr {
                if !recommendedBooksArr.contains(book) {
                    let doc = self.db.collection("Owners").document(email)
                    let titleForDeleting = book.title
                    doc.updateData(["recommendedBooks.\(titleForDeleting)" : FieldValue.delete()]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            print("Document successfully deleted")
                        }
                    }
                }
            }
        })
    }
    
    func setRecommendedBooks(recommendedBooksArr: [BookInfo], email: String) {
        if recommendedBooksArr != [] {
            for recbook in recommendedBooksArr {
                let doc = db.collection("Owners").document(email)
                doc.updateData([
                    "recommendedBooks.\(recbook.title)": ["title" : recbook.title, "author" :  recbook.author, "publishYear" :  "\(recbook.publishYear)", "genre" :  recbook.genre, "pagesCount" :  "\(recbook.pagesCount)", "language" :  recbook.language, "price" :  "\(recbook.price)", "additionalInfo" : recbook.additionalInfo, "addingDate" : recbook.addingDate]
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully added")
                    }
                }
            }
        }
    }
    
    func deleteBookFromDB(email: String, bookInfo: BookInfo) {
        let doc = db.collection("Owners").document(email)
        let title = bookInfo.title
        doc.updateData(["books.\(title)" : FieldValue.delete()])
        
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var title = ""
            var author = ""
            var publishYear = ""
            var genre = ""
            var pagesCount = ""
            var language = ""
            var price = ""
            var additionalInfo = ""
            var addingDate = ""
            
            let booksFromDBTemp = res?.get("recommendedBooks")
            let checkCount_1 = booksFromDBTemp as? NSDictionary
            
            guard checkCount_1 != nil else {
                print("err")
                return
            }
            var booksFromDBArr: [BookInfo] = []
            let booksFromDB = booksFromDBTemp as! NSDictionary
            
            
            for info in booksFromDB {
                let infoValues = info.value as! NSDictionary
                for someInfoValue in infoValues {
                    if "\(someInfoValue.key)" == "title" {
                        title = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "author" {
                        author = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "publishYear" {
                        publishYear = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "genre" {
                        genre = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "pagesCount" {
                        pagesCount = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "language" {
                        language = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "price" {
                        price = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "additionalInfo" {
                        additionalInfo = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "addingDate" {
                        addingDate = "\(someInfoValue.value)"
                    }
                }
                let bookFromDB: BookInfo = BookInfo(title: title, author: author, publishYear: Int(publishYear) ?? 0, genre: genre, pagesCount: Int(pagesCount) ?? 0, language: language, price: Double(price) ?? 0.0, additionalInfo: additionalInfo, addingDate: addingDate)
                booksFromDBArr.append(bookFromDB)
            }
            
            if booksFromDBArr.contains(bookInfo) {
                let doc = self.db.collection("Owners").document(email)
                let titleForDeleting = bookInfo.title
                doc.updateData(["recommendedBooks.\(titleForDeleting)" : FieldValue.delete()]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully deleted")
                    }
                }
            }
        })
    }
    
    func editLibraryOwnersNameFirestore(name: String, email: String) {
        db.collection("Owners").document(email).setData(["Owners name": name], merge: true)
    }
    
    func editBookstoreAndOwnersDataFirestore(location: String, email: String, phoneNumber: String, exchangePreference: String) {
        db.collection("Owners").document(email).setData(["location" : location,
                                                         "phoneNumber": phoneNumber, "preference": exchangePreference], merge: true)
    }
    
    func getBooks(email: String, completion: @escaping (_ books: [BookInfo]) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var booksArr: [BookInfo] = []
            var title = ""
            var author = ""
            var publishYear = ""
            var genre = ""
            var pagesCount = ""
            var language = ""
            var price = ""
            var additionalInfo = ""
            var addingDate = ""
            
            
            let booksDict = res?.get("books")
            let checkCount_1 = booksDict as? NSDictionary
            
            guard checkCount_1 != nil else {
                completion([])
                print("err")
                return
            }
            
            let books = booksDict as! NSDictionary
            
            for info in books {
                let infoValues = info.value as! NSDictionary
                for someInfoValue in infoValues {
                    if "\(someInfoValue.key)" == "title" {
                        title = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "author" {
                        author = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "publishYear" {
                        publishYear = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "genre" {
                        genre = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "pagesCount" {
                        pagesCount = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "language" {
                        language = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "price" {
                        price = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "additionalInfo" {
                        additionalInfo = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "addingDate" {
                        addingDate = "\(someInfoValue.value)"
                    }
                }
                let book: BookInfo = BookInfo(title: title, author: author, publishYear: Int(publishYear) ?? 0, genre: genre, pagesCount: Int(pagesCount) ?? 0, language: language, price: Double(price) ?? 0.0, additionalInfo: additionalInfo, addingDate: addingDate)
                booksArr.append(book)
            }
            completion(booksArr)
        })
    }
    
    func deleteApplication(email: String, applicaton: ApplicationMainInfo) {
        db.collection("Owners").document(email).updateData(["Applications.\(applicaton.book.title)" : FieldValue.delete()]){ err in
            if let err = err {
                print("Error updating document \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func checkForValidPasswordForEmailLogin(email: String, password: String,  _ completion: @escaping (_ valid: Bool, _ bookstoreData: Bookstore) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            let bookstorePassword = res?.get("password")
            if password == "\(bookstorePassword ?? "")" {
                let books: [BookInfo] = res?.get("books") as? [BookInfo] ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
                
                let bookstore = Bookstore(name: "\(res?.get("name") ?? "")", ownersName: "\(res?.get("Owners name") ?? "Set your name")", password: "\(res?.get("password") ?? "")", preference: "\(res?.get("preference")  ?? "")", phoneNumber: "\(res?.get("phoneNumber") ?? "")" , email: email, location: "\(res?.get("location") ?? "")", additionalInfo: "\(res?.get("additionalInfo") ?? "")", books: books)
                
                completion(true, bookstore)
            } else {
                completion(false, Bookstore(name: "", ownersName: "Set your name", password: "", preference: "", phoneNumber: "", email: "", location: "", additionalInfo: "", books: []) )
            }
        })
    }
    
    func checkForValidPasswordForNameLogin(bookstoreName: String, password: String,  _ completion: @escaping (_ valid: Bool, _ bookstoreData: Bookstore) -> Void) {
        db.collection("Owners").whereField("name", isEqualTo: bookstoreName).getDocuments(completion: { res, err in
            for bookstore in res!.documents {
                if res == nil {
                    completion(false, Bookstore(name: "", ownersName: "Set your name", password: "", preference: "", phoneNumber: "", email: "", location: "", additionalInfo: "", books: []) )
                }
                let bookstorePassword = bookstore.get("password")
                if password == "\(bookstorePassword ?? "")" {
                    let books: [BookInfo] = bookstore.get("books") as? [BookInfo] ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
                    
                    let bookstore = Bookstore(name: bookstoreName, ownersName: "\(bookstore.get("Owners name") ?? "Set your name")", password: "\(bookstore.get("password") ?? "")", preference: "\(bookstore.get("preference")  ?? "")", phoneNumber: "\(bookstore.get("phoneNumber") ?? "")" , email: "\(bookstore.get("email") ?? "")", location: "\(bookstore.get("location") ?? "")", additionalInfo: "\(bookstore.get("additionalInfo") ?? "")", books: books)
                    
                    completion(true, bookstore)
                } else {
                    completion(false, Bookstore(name: "", ownersName: "Set your name", password: "", preference: "", phoneNumber: "", email: "", location: "", additionalInfo: "", books: []) )
                }
            }
        })
    }
    
    func checkForBookstoreNameExisting(bookstoreName: String, _ completion: @escaping (_ nameExists: Bool) -> Void) {
        let bookstores = db.collection("Owners")
        bookstores.getDocuments { query, err in
            var boolean = false
            guard let docs = query?.documents else { return }
            for _ in docs {
                self.getNamesData(completion: { arr in
                    for name in arr {
                        if name == "\(bookstoreName)" {
                            completion(true)
                            boolean = true
                        }
                    }
                    if !boolean {
                        completion(false)
                    }
                })
            }
        }
    }
    
    func getApplications(email: String, completion: @escaping (_ appls: [ApplicationMainInfo]) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var applications: [ApplicationMainInfo] = []
            var bookData: BookInfo = BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")
            var userInfo = ""
            var type = ""
            var status = false
            var additionalInfo = ""
            var date = ""
            var bookstoreName = ""
            var userEmail = ""
            var bookstoreEmail = ""
            
            let applicationsDB = res?.get("Applications")
            
            let temp = applicationsDB as? NSDictionary
            guard temp != nil else {
                print("error")
                completion([])
                return
            }
            for applicationDict in applicationsDB as! NSDictionary {
                let temp_2 = applicationDict.value as? NSDictionary
                guard temp_2 != nil else {
                    print("error")
                    completion([])
                    return
                }
                
                for application in applicationDict.value as! NSDictionary {
                    if "\(application.key)" == "BookInfo" {
                        for bookInfo in application.value as! NSDictionary {
                            if "\(bookInfo.key)" == "title" {
                                bookData.title = "\(bookInfo.value)"
                            } else if "\(bookInfo.key)" == "author" {
                                bookData.author = "\(bookInfo.value)"
                            }
                        }
                    } else if "\(application.key)" == "Additional info" {
                        additionalInfo = "\(application.value)"
                    } else if "\(application.key)" == "Date" {
                        date = "\(application.value)"
                    } else if "\(application.key)" == "Status" {
                        status = application.value as! Bool
                    } else if "\(application.key)" == "Type" {
                        type = "\(application.value)"
                    } else if "\(application.key)" == "UserInfo" {
                        userInfo = "\(application.value)"
                    } else if "\(application.key)" == "bookstoreName" {
                        bookstoreName = "\(application.value)"
                    } else if "\(application.key)" == "UserEmail" {
                        userEmail = "\(application.value)"
                    } else if "\(application.key)" == "BookstoreEmail" {
                        bookstoreEmail = "\(application.value)"
                    }
                }
                applications.append(ApplicationMainInfo(userInfo: userInfo, book: bookData, date: date, status: status, type: type, additionalInfo: additionalInfo, bookstoreName: bookstoreName, userEmail: userEmail, bookstoreEmail: bookstoreEmail))
            }
            completion(applications)
        })
    }
    
    func getNamesData(completion: @escaping ([String]) -> ()) {
        db.collection("Owners").getDocuments() { (querySnapshot, err) in
            guard let querySnapshot = querySnapshot else { return }
            var arr: [String] = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot.documents {
                    arr.append("\(document.get("name") ?? "")")
                }
                arr = arr.filter { $0 != "" }
                completion(arr)
            }
        }
    }
    
    func checkForValidPasswordForUserEmailLogin(email: String, password: String,  _ completion: @escaping (_ valid: Bool, _ userData: User) -> Void) {
        db.collection("Users").document(email).getDocument(completion: { user, err in
            let userPassword = user?.get("password")
            if password == "\(userPassword ?? "")" {
                
                let user = User(firstName: "\(user?.get("firstName") ?? "")", lastName: "\(user?.get("lastName") ?? "")", age: user?.get("age") as! Int, password: "\(user?.get("password") ?? "")", email: email, username: "\(user?.get("username") ?? "")", phoneNumber: "\(user?.get("phoneNumber") ?? "")", location: "\(user?.get("location") ?? "")")
                
                completion(true, user)
            } else {
                completion(false, User(firstName: "", lastName: "", age: 0, password: "", email: "", username: "", phoneNumber: "", location: "") )
            }
        })
    }
    
    func checkForValidPasswordForUsernameLogin(username: String, password: String,  _ completion: @escaping (_ valid: Bool, _ userData: User) -> Void) {
        db.collection("Users").whereField("username", isEqualTo: username).getDocuments(completion: { res, err in
            guard let docs = res?.documents else { return }
            for user in docs {
                if res == nil {
                    completion(false, User(firstName: "", lastName: "", age: 0, password: "", email: "", username: "", phoneNumber: "", location: "") )
                }
                
                let userPassword = user.get("password")
                if password == "\(userPassword ?? "")" {
                    let user = User(firstName: "\(user.get("firstName") ?? "")", lastName: "\(user.get("lastName") ?? "")", age: user.get("age") as! Int, password: "\(user.get("password") ?? "")", email: "\(user.get("email") ?? "")", username: username, phoneNumber: "\(user.get("phoneNumber") ?? "")", location: "\(user.get("location") ?? "")")
                    
                    completion(true, user)
                } else {
                    completion(false, User(firstName: "", lastName: "", age: 0, password: "", email: "", username: "", phoneNumber: "", location: "") )
                }
            }
        })
    }
    
    func getUsernamesData(completion: @escaping ([String]) -> ()) {
        db.collection("Users").getDocuments() { (querySnapshot, err) in
            guard let querySnapshot = querySnapshot else { return }
            var arr: [String] = []
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot.documents {
                    arr.append("\(document.get("username") ?? "")")
                }
                completion(arr)
            }
        }
    }
    
    func configureRecentlyAddedBooks(email: String, completion: @escaping (_ arr: [BookInfo]) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var books: [BookInfo] = []
            var booksArr: [BookInfo] = []
            
            let temp = res?.get("books") as? NSDictionary
            
            if temp == nil {
                print("error getting books")
                completion([])
                return
            }
            
            let randomBooksArr = res?.get("books") as! NSDictionary
            for info in randomBooksArr {
                let infoValues = info.value as! NSDictionary
                var title = ""
                var author = ""
                var publishYear = ""
                var genre = ""
                var pagesCount = ""
                var language = ""
                var price = ""
                var additionalInfo = ""
                var addingDate = ""
                
                for someInfoValue in infoValues {
                    if "\(someInfoValue.key)" == "title" {
                        title = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "author" {
                        author = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "publishYear" {
                        publishYear = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "genre" {
                        genre = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "pagesCount" {
                        pagesCount = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "language" {
                        language = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "price" {
                        price = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "additionalInfo" {
                        additionalInfo = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "addingDate" {
                        addingDate = "\(someInfoValue.value)"
                    }
                }
                let book: BookInfo = BookInfo(title: title, author: author, publishYear: Int(publishYear) ?? 0, genre: genre, pagesCount: Int(pagesCount) ?? 0, language: language, price: Double(price) ?? 0.0, additionalInfo: additionalInfo, addingDate: addingDate)
                books.append(book)
            }
            let format = "dd-MMM-yyyy"
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
            dateFormatter.dateFormat = format
            
            booksArr = books.sorted { dateFormatter.date(from: $0.addingDate)! > dateFormatter.date(from: $1.addingDate)! }
            
            completion(booksArr)
        })
    }
    
    func configureRandomBooksOfRandomGenre(email: String, completion: @escaping (_ arr: [BookInfo]) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var books: [BookInfo] = []
            let temp = res?.get("books") as? NSDictionary
            
            if temp == nil {
                print("error getting books")
                completion([])
                return
            }
            
            let recommendedBooksArr = res?.get("books") as! NSDictionary
            for info in recommendedBooksArr {
                let infoValues = info.value as! NSDictionary
                var title = ""
                var author = ""
                var publishYear = ""
                var genre = ""
                var pagesCount = ""
                var language = ""
                var price = ""
                var additionalInfo = ""
                for someInfoValue in infoValues {
                    if "\(someInfoValue.key)" == "title" {
                        title = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "author" {
                        author = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "publishYear" {
                        publishYear = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "genre" {
                        genre = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "pagesCount" {
                        pagesCount = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "language" {
                        language = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "price" {
                        price = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "additionalInfo" {
                        additionalInfo = "\(someInfoValue.value)"
                    }
                }
                let book: BookInfo = BookInfo(title: title, author: author, publishYear: Int(publishYear) ?? 0, genre: genre, pagesCount: Int(pagesCount) ?? 0, language: language, price: Double(price) ?? 0.0, additionalInfo: additionalInfo, addingDate: "")
                books.append(book)
            }
            
            var booksArr: [BookInfo] = []
            var genres: [String] = []
            var genre: String = ""
            
            for book in books {
                genres.append(book.genre)
            }
            
            genre = genres.randomElement()!
            booksArr = books.filter { $0.genre == genre }
            
            var randBooks: [BookInfo] = []
            
            randBooks.append(booksArr.randomElement()!)
            randBooks.append(booksArr.randomElement()!)
            randBooks.append(booksArr.randomElement()!)
            randBooks.append(booksArr.randomElement()!)
            randBooks.append(booksArr.randomElement()!)
            
            randBooks = randBooks.unique
            
            completion(randBooks)
        })
    }
    
    
    func getRecommendedBooks(email: String, completion: @escaping (_ arr: [BookInfo]) -> Void) {
        db.collection("Owners").document(email).getDocument(completion: { res, err in
            var booksArr: [BookInfo] = []
            
            var title = ""
            var author = ""
            var publishYear = ""
            var genre = ""
            var pagesCount = ""
            var language = ""
            var price = ""
            var additionalInfo = ""
            
            let temp = res?.get("recommendedBooks") as? NSDictionary
            
            guard temp != nil else {
                print("error getting recbooks")
                completion([])
                return
            }
            
            let recommendedBooksArr = res?.get("recommendedBooks") as! NSDictionary
            for info in recommendedBooksArr {
                let infoValues = info.value as! NSDictionary
                for someInfoValue in infoValues {
                    if "\(someInfoValue.key)" == "title" {
                        title = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "author" {
                        author = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "publishYear" {
                        publishYear = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "genre" {
                        genre = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "pagesCount" {
                        pagesCount = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "language" {
                        language = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "price" {
                        price = "\(someInfoValue.value)"
                    } else if "\(someInfoValue.key)" == "additionalInfo" {
                        additionalInfo = "\(someInfoValue.value)"
                    }
                }
                let book: BookInfo = BookInfo(title: title, author: author, publishYear: Int(publishYear) ?? 0, genre: genre, pagesCount: Int(pagesCount) ?? 0, language: language, price: Double(price) ?? 0.0, additionalInfo: additionalInfo, addingDate: "")
                booksArr.append(book)
            }
            completion(booksArr)
        })
        
    }
    
    func getUsersApplications(email: String, completion: @escaping (_ appls: [ApplicationMainInfo]) -> Void) {
        db.collection("Users").document(email).getDocument(completion: { res, err in
            guard let document = res else {
                print("error getting docs")
                return }
            
            var applications: [ApplicationMainInfo] = []
            var bookData: BookInfo = BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")
            var type = ""
            var status = false
            var additionalInfo = ""
            var date = ""
            var bookstoreName = ""
            var bookstoreEmail = ""
            var userEmail = ""
            
            let applicationsDB = document.get("Applications")
            if applicationsDB != nil {
                let temp = applicationsDB as? NSDictionary
                guard temp != nil else {
                    print("error")
                    completion([])
                    return
                }
                
                for applicationDict in applicationsDB as! NSDictionary {
                    let temp_2 = applicationDict.value as? NSDictionary
                    guard temp_2 != nil else {
                        print("error")
                        completion([])
                        return
                    }
                    for applicationTest in applicationDict.value as! NSDictionary {
                        if "\(applicationTest.key)" == "UserEmail" {
                            if email == "\(applicationTest.value)" {
                                for application in applicationDict.value as! NSDictionary {
                                    if "\(application.key)" == "BookInfo" {
                                        for bookInfo in application.value as! NSDictionary {
                                            if "\(bookInfo.key)" == "title" {
                                                bookData.title = "\(bookInfo.value)"
                                            } else if "\(bookInfo.key)" == "author" {
                                                bookData.author = "\(bookInfo.value)"
                                            }
                                        }
                                    } else if "\(application.key)" == "Additional info" {
                                        additionalInfo = "\(application.value)"
                                    } else if "\(application.key)" == "Date" {
                                        date = "\(application.value)"
                                    } else if "\(application.key)" == "Status" {
                                        status = application.value as! Bool
                                    } else if "\(application.key)" == "Type" {
                                        type = "\(application.value)"
                                    } else if "\(application.key)" == "bookstoreName" {
                                        bookstoreName = "\(application.value)"
                                    }
                                    else if "\(application.key)" == "UserEmail" {
                                        userEmail = "\(application.value)"
                                    }
                                    else if "\(application.key)" == "BookstoreEmail" {
                                        bookstoreEmail = "\(application.value)"
                                    }
                                }
                            }
                        }
                    }
                    if date != "" && type != "" && bookstoreName != "" {
                        applications.append(ApplicationMainInfo(userInfo: "", book: bookData, date: date, status: status, type: type, additionalInfo: additionalInfo, bookstoreName: bookstoreName, userEmail: userEmail, bookstoreEmail: bookstoreEmail))
                    } else {
                        print("application data nil")
                    }
                }
            }
            completion(applications)
        })
    }
    
    func getBookstoresWithChoosedLocation(location: String, _ completion: @escaping (_ success: Bool, _ arr: [String]) -> Void) {
        db.collection("Owners").whereField("location", isEqualTo: location).getDocuments(completion: { res, err in
            if err != nil {
                completion(false, [])
            }
            var arr: [String] = []
            for doc in res!.documents {
                arr.append("\(doc.get("name") ?? "")")
            }
            
            arr = arr.filter { $0 != "" }
            
            if arr != [] {
                completion(true, arr)
            } else {
                completion(false, [])
            }
        })
    }
    
    func getBookstoresWithChoosedPreference(preference: String, _ completion: @escaping (_ success: Bool, _ arr: [String]) -> Void) {
        db.collection("Owners").whereField("preference", isEqualTo: preference).getDocuments(completion: { res, err in
            if err != nil {
                completion(false, [])
            }
            
            var arr: [String] = []
            for doc in res!.documents {
                arr.append("\(doc.get("name") ?? "")")
            }
            
            arr = arr.filter { $0 != "" }
            
            if arr != [] {
                completion(true, arr)
            } else {
                completion(false, [])
            }
        })
    }
    
    func getBookstoreData(name: String, completion: @escaping (Bookstore) -> ()) {
        db.collection("Owners").whereField("name", isEqualTo: name).getDocuments() { (document, err) in
            guard let document = document else { return }
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for bookstore in document.documents {
                    let books: [BookInfo] = bookstore.get("books") as? [BookInfo] ?? [BookInfo(title: "", author: "", publishYear: 0, genre: "", pagesCount: 0, language: "", price: 0, additionalInfo: "", addingDate: "")]
                    
                    let bookstore = Bookstore(name: name, ownersName: "\(bookstore.get("Owners name") ?? "Set your name")", password: "\(bookstore.get("password") ?? "")", preference: "\(bookstore.get("preference")  ?? "")", phoneNumber: "\(bookstore.get("phoneNumber") ?? "")" , email: "\(bookstore.get("email") ?? "")", location: "\(bookstore.get("location") ?? "")", additionalInfo: "\(bookstore.get("additionalInfo") ?? "")", books: books)
                    completion(bookstore)
                }
            }
        }
    }
    
    func sendApplication(email: String, application: Application, completion: @escaping (_ success: Bool) -> Void) {
        db.collection("Owners").document(email).updateData(["Applications.\(application.book.title)" : ["UserInfo" : application.userInfo, "UserEmail" : application.user.email, "Username" : application.user.username, "BookstoreEmail" : application.bookstore.email, "Bookstore name" : application.bookstore.name, "Date" : application.date, "Status" : application.status, "Type" : application.type, "Additional info" : application.additionalInfo, "BookInfo" : ["title" : application.book.title, "author" :  application.book.author, "publishYear" :  "\(application.book.publishYear)", "genre" :  application.book.genre, "pagesCount" :  "\(application.book.pagesCount)", "language" :  application.book.language, "price" :  "\(application.book.price)", "additionalInfo" :  application.book.additionalInfo]] as [String : Any]]) { err in
            if let err = err {
                completion(false)
                print("Error updating document: \(err)")
            } else {
                completion(true)
                print("Document successfully added")
            }
        }
        
        db.collection("Users").document(application.user.email).updateData(["Applications.\(application.book.title)" : ["UserInfo" : application.userInfo, "UserEmail" : application.user.email, "Username" : application.user.username, "BookstoreEmail" : application.bookstore.email, "Bookstore name" : application.bookstore.name, "Date" : application.date, "Status" : application.status, "Type" : application.type, "Additional info" : application.additionalInfo, "bookstoreName" : application.bookstore.name, "BookInfo" : ["title" : application.book.title, "author" :  application.book.author, "publishYear" :  "\(application.book.publishYear)", "genre" :  application.book.genre, "pagesCount" :  "\(application.book.pagesCount)", "language" :  application.book.language, "price" :  "\(application.book.price)", "additionalInfo" :  application.book.additionalInfo]] as [String : Any]]) { err in
            if let err = err {
                completion(false)
                print("Error updating document: \(err)")
            } else {
                completion(true)
                print("Document successfully added")
            }
        }
    }
    
    func setStatusInDB(email: String, title: String, status: Bool, application: ApplicationMainInfo) {
        db.collection("Owners").document(email).updateData(["Applications.\(title).Status" : status]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully added")
            }
        }
        
        db.collection("Users").document(application.userEmail).updateData(["Applications.\(title).Status" : status]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully added")
            }
        }
    }
    
    func editUserData(phoneNumber: String, address: String, email: String) {
        db.collection("Users").document(email).setData(["location": address,
                                                        "phoneNumber": phoneNumber], merge: true)
    }
}
