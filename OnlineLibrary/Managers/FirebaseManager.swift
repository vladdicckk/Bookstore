//
//  FirebaseManager.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//


import UIKit
import FirebaseDatabase
import MessageKit
import CoreLocation

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let db = Database.database().reference()
    
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    func getUsersConversationsEmails(email: String, completion: @escaping ([String]) -> Void) {
        let safeEmail = FirebaseManager.safeEmail(email: email)
        db.child("\(safeEmail)/Conversations").observeSingleEvent(of: .value, with: { res in
            guard let convs = res.value as? [[String: Any]] else {
                print("Conversations for email \(safeEmail) are empty")
                completion([])
                return }
            var emailsArr: [String] = []
            for conv in convs {
                guard let email = conv["otherUserEmail"] as? String else {
                    print("Email getting err")
                    return }
                emailsArr.append(email)
            }
            completion(emailsArr)
        })
    }
    
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        var safeEmail = user.email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        db.child(user.safeEmail).setValue([
            "name" : user.name,
            "surname" : user.surname,
            "email" : user.email
        ]) { err, _  in
            if let err = err {
                print("Failed to insert user, err: \(err)")
                completion(false)
            } else {
                print("User successfully inserted")
            }
        }
        
        db.child("users").observeSingleEvent(of: .value, with: { [weak self] res in
            if var usersCollection = res.value as? [[String: String]] {
                usersCollection.append([
                    "name" : user.name + " " + user.surname,
                    "email" : safeEmail
                ])
                
                self?.db.child("users").setValue(usersCollection) { err, _  in
                    if let err = err {
                        print("Failed to insert user, err: \(err)")
                        completion(false)
                    } else {
                        completion(true)
                        print("User successfully inserted")
                    }
                }
            } else {
                let newCollection: [[String: String]] = [[
                    "name" : user.name + " " + user.surname,
                    "email" : safeEmail
                ]]
                self?.db.child("users").setValue(newCollection) { err, _  in
                    if let err = err {
                        print("Failed to insert user, err: \(err)")
                        completion(false)
                    } else {
                        completion(true)
                        print("User successfully inserted")
                    }
                }
            }
        })
    }
    
    public func userExists(with email: String, completion: @escaping (Bool) -> Void) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        db.child("users").observeSingleEvent(of: .value, with: { res in
            guard let dict = res.value as? [[String: String]] else {
                print("Dict not exists")
                completion(false)
                return
            }
            var isExists = false
            for user in dict {
                if user["email"] == safeEmail {
                    isExists = true
                    completion(true)
                }
            }
            if !isExists {
                completion(false)
            }
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        db.child("users").observeSingleEvent(of: .value, with: { res in
            guard let value = res.value as? [[String: String]] else {
                completion(.failure(FirebaseErrors.failedToGetUsersData))
                return }
            completion(.success(value))
        })
    }
    
    func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        db.child(path).observeSingleEvent(of: .value, with: { res in
            guard let value = res.value else {
                completion(.failure(FirebaseErrors.failedToGetUsersData))
                return }
            completion(.success(value))
        })
    }
}

public enum FirebaseErrors: Error {
    case failedToGetUsersData
    case failedToGetUsersConversations
}

extension FirebaseManager {
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, id: String, currentEmail: String, currentName: String , completion: @escaping (Bool) -> Void) {
        let email = currentEmail
        let safeEmail = FirebaseManager.safeEmail(email: email)
        db.child(safeEmail).observeSingleEvent(of: .value, with: { [weak self] res in
            guard var userNode = res.value as? [String: Any] else {
                print("user node empty")
                completion(false)
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            
            let conversationId = "conversation_\(id)"
            
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": "false"
                ],
                "otherUserEmail": otherUserEmail,
                "name": name
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "otherUserEmail": safeEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": "false"
                ],
                "name": currentName
            ]
            
            self?.db.child("\(otherUserEmail)/Conversations").observeSingleEvent(of: .value, with: { [weak self]  res in
                if var conversations = res.value as? [[String: Any]] {
                    conversations.append(recipient_newConversationData)
                    self?.db.child("\(otherUserEmail)/Conversations").setValue(conversations) { [weak self]  err, _  in
                        if let err = err {
                            print("Failed to insert conversation, err: \(err)")
                            completion(false)
                        } else {
                            self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, currentEmail: currentEmail, completion: { success in
                                if success {
                                    completion(true)
                                    print("Conversation successfully inserted")
                                } else {
                                    print("Conversation insert failed")
                                }
                            })
                        }
                    }
                } else {
                    self?.db.child("\(otherUserEmail)/Conversations").setValue([recipient_newConversationData]) { [weak self]  err, _  in
                        if let err = err {
                            print("Failed to insert conversation, err: \(err)")
                            completion(false)
                        } else {
                            self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, currentEmail: currentEmail, completion: { success in
                                if success {
                                    completion(true)
                                    print("Conversation successfully inserted")
                                } else {
                                    print("Conversation insert failed")
                                }
                            })
                        }
                    }
                }
            })
            
            if var conversationData = userNode["Conversations"] as? [[String: Any]] {
                conversationData.append(newConversationData)
                userNode["Conversations"] = conversationData
                self?.db.child(safeEmail).setValue(userNode) { [weak self] err, _  in
                    if let err = err {
                        print("Failed to insert conversation, err: \(err)")
                        completion(false)
                    } else {
                        self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, currentEmail: currentEmail, completion: { success in
                            if success {
                                completion(true)
                                print("Conversation successfully inserted")
                            } else {
                                print("Conversation insert failed")
                            }
                        })
                    }
                }
            } else {
                userNode["Conversations"] = [newConversationData]
                self?.db.child(safeEmail).setValue(userNode) { [weak self]  err, _  in
                    if let err = err {
                        print("Failed to insert conversation, err: \(err)")
                        completion(false)
                    } else {
                        self?.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, currentEmail: currentEmail, completion: { success in
                            if success {
                                completion(true)
                                print("Conversation successfully inserted")
                            } else {
                                print("Conversation insert failed")
                            }
                        })
                    }
                }
            }
        })
    }
    
    func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, currentEmail: String, completion: @escaping (Bool) -> Void) {
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var messageTxt = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            messageTxt = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let currentUserEmail = currentEmail
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": messageTxt,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": "false",
            "name": name
        ]
        
        db.child(conversationID).observeSingleEvent(of: .value, with: { [weak self] res in
            let value: [String: Any] = [
                "messages" : [ message ]
            ]
            self?.db.child("\(conversationID)").setValue(value) { err, _ in
                if let err = err {
                    print("Failed start conversation: \(err)")
                } else {
                    print("Conversation successfully started")
                }
            }
        })
    }
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        db.child("\(email)/Conversations").observeSingleEvent(of: .value, with: { res in
            guard let value = res.value as? [[String: Any]] else {
                completion(.failure(FirebaseErrors.failedToGetUsersConversations))
                return
            }
            let conversations: [Conversation] = value.compactMap({ dict in
                guard let conversationId = dict["id"] as? String,
                      let otherUserEmail = dict["otherUserEmail"] as? String ,
                      let name = dict["name"] as? String,
                      let latestMessage = dict["latest_message"] as? [String: Any],
                      let sent = latestMessage["date"] as? String ,
                      let isRead = latestMessage["is_read"] as? String,
                      let message = latestMessage["message"] as? String  else {
                    print("Failed to get conversations info")
                    return Conversation(id: "", name: "", latestMessage: LatestMessage(date: "", isRead: false, message: ""), otherUserEmail: "") }
                let latestMessageObj = LatestMessage(date: sent, isRead: Bool(isRead)!, message: message)
                return Conversation(id: conversationId, name: name, latestMessage: latestMessageObj, otherUserEmail: otherUserEmail)
            })
            completion(.success(conversations))
        })
    }
    
    public func getAllMessangesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        db.child("\(id)/messages").observeSingleEvent(of: .value, with: { res in
            guard let value = res.value as? [[String: Any]] else {
                completion(.failure(FirebaseErrors.failedToGetUsersConversations))
                return
            }

            let messages: [Message] = value.compactMap ({ dict in
                guard let name = dict["name"] as? String, let messageID = dict["id"] as? String, let senderEmail = dict["sender_email"] as? String, let dateString = dict["date"] as? String, let content = dict["content"] as? String, let type = dict["type"] as? String else {
                    print("errrr")
                    let senderObj = Sender(photoURL: "", senderId: "", displayName: "")
                    return Message(sender: senderObj, messageId: "", sentDate: Date(), kind: .text(""))
                }
                let dateFormatter = DateFormatter()
                var date: Date = Date()
                dateFormatter.dateFormat = "YYYY_mm_dd HH:mm:ss"
                if let tempDate = dateFormatter.date(from: dateString)  {
                    date = tempDate
                } else {
                    dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                    guard let tempDate = dateFormatter.date(from: dateString) else {
                        print("errrrrrrr")
                        let senderObj = Sender(photoURL: "", senderId: "", displayName: "")
                        return Message(sender: senderObj, messageId: "", sentDate: Date(), kind: .text(""))
                    }
                    date = tempDate
                }
                var kind: MessageKind?

                if type == "photo" {
                    guard let imageUrl = URL(string: content) else {
                        print("errrrrrrr")
                        let senderObj = Sender(photoURL: "", senderId: "", displayName: "")
                        return Message(sender: senderObj, messageId: "", sentDate: Date(), kind: .text(""))
                    }
                    let media = Media(url: imageUrl, placeholderImage: UIImage(), size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string: content), let placeholder = UIImage(named: "empty") else {
                        print("errrrrrrr")
                        let senderObj = Sender(photoURL: "", senderId: "", displayName: "")
                        return Message(sender: senderObj, messageId: "", sentDate: Date(), kind: .text(""))
                    }
                    let media = Media(url: videoUrl, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                } else if type == "location" {
                    var locationComponents = content.components(separatedBy: ",")
                    locationComponents[1] = locationComponents[1].replacingOccurrences(of: " ", with: "")
                    guard let longitude = Double(locationComponents[1]), let latitude = Double(locationComponents[0]) else {
                        print("errrr_r")
                        let senderObj = Sender(photoURL: "", senderId: "", displayName: "")
                        return Message(sender: senderObj, messageId: "", sentDate: Date(), kind: .text(""))
                    }
                    let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
                    kind = .location(location)
                } else {
                    kind = .text(content)
                }
                guard let finalKind = kind else {
                    print("errrr_r")
                    let senderObj = Sender(photoURL: "", senderId: "", displayName: "")
                    return Message(sender: senderObj, messageId: "", sentDate: Date(), kind: .text(""))
                }
                let senderObj = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: senderObj, messageId: messageID, sentDate: date, kind: finalKind)
            })
            completion(.success(messages))
        })
    }
    
    public func sendMessage(otherUserEmail: String , name: String, to conversation: String, message: Message, email: String, completion: @escaping (Bool) -> Void) {
        // add new message to arr
        // update sender latest message
        // update recipient latest message
        let myEmail = email
        
        let currentEmail = FirebaseManager.safeEmail(email: myEmail)
        
        db.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] res in
            guard let strongSelf = self else { return }
            guard var currentMessages = res.value as? [[String: Any]] else {
                print("current messages not equals [[String: Any]] or empty")
                completion(false)
                return }
            let messageDate = message.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            var messageTxt = ""
            
            switch message.kind {
            case .text(let messageText):
                messageTxt = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageTxt = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageTxt = targetUrlString
                }
                break
            case .location(let locationItem):
                let location = locationItem.location
                messageTxt = "\(location.coordinate.longitude), \(location.coordinate.latitude)"
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let currentUserEmail = email
            
            let messageDict: [String: Any] = [
                "id": "\(message.messageId)",
                "type": "\(message.kind.messageKindString)",
                "content": "\(messageTxt)",
                "date": "\(dateString)",
                "sender_email": "\(currentUserEmail)",
                "is_read": "false",
                "name": "\(name)"
            ]
            
            currentMessages.append(messageDict)
            
            strongSelf.db.child("\(conversation)/messages").setValue(currentMessages) { err, _ in
                guard err == nil else {
                    print("err setting messages")
                    completion(false)
                    return
                }
                
                strongSelf.db.child("\(currentEmail)/Conversations").observeSingleEvent(of: .value, with: { res in
                    guard var currentUserConvs = res.value as? [[String : Any]] else {
                        print("current user convs not equals [[String: Any]] or empty")
                        completion(false)
                        return }
                    
                    let updatedValue: [String: Any] = [
                        "date": "\(dateString)",
                        "is_read" : "false",
                        "message" : "\(messageTxt)"
                    ]
                    var position = 0
                    
                    var targetConversation: [String: Any]?
                    
                    for conv in currentUserConvs {
                        if let convId = conv["id"] as? String, convId == conversation {
                            targetConversation = conv
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let currentTargetConversation = targetConversation else {
                        print("target conversation nil")
                        return }
                    
                    if !currentTargetConversation.isEmpty {
                        currentUserConvs[position] = currentTargetConversation
                        strongSelf.db.child("\(currentEmail)").updateChildValues(["Conversations": currentUserConvs as NSArray], withCompletionBlock: { err, _ in
                            if let err = err {
                                print(err)
                                completion(false)
                            }
                        })
                        
                        strongSelf.db.child("\(otherUserEmail)/Conversations").observeSingleEvent(of: .value, with: { res in
                            guard var otherUserConvs = res.value as? [[String : Any]] else {
                                print("current user convs not equals [[String: Any]] or empty")
                                completion(false)
                                return }
                            
                            let updatedValue: [String: Any] = [
                                "date": "\(dateString)",
                                "is_read" : "false",
                                "message" : "\(messageTxt)"
                            ]
                            var position = 0
                            
                            var targetConversation: [String: Any]?
                            
                            for conv in otherUserConvs {
                                if let convId = conv["id"] as? String, convId == conversation {
                                    targetConversation = conv
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let currentTargetConversation = targetConversation else {
                                print("target conversation nil")
                                return }
                            
                            if !currentTargetConversation.isEmpty {
                                otherUserConvs[position] = currentTargetConversation
                                strongSelf.db.child("\(otherUserEmail)").updateChildValues(["Conversations": otherUserConvs as NSArray], withCompletionBlock: { err, _ in
                                    if let err = err {
                                        print(err)
                                        completion(false)
                                    } else {
                                        completion(true)
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
    
    // TODO: finish deleting convs
    func deleteConversation(conversationId: String, email: String , completion: @escaping (Bool) -> Void) {
        let safeEmail = FirebaseManager.safeEmail(email: email)
        // get all convs for current user
        // delete conv in collection
        db.child("\(safeEmail)/Conversations").observeSingleEvent(of: .value, with: { [weak self] res in
            if var convs = res.value as? [[String: Any]] {
                var positionToRemove = 0
                for conv in convs {
                    if let id = conv["id"] as? String, id == id {
                        break
                    }
                    positionToRemove += 1
                }
                guard let otherEmail = convs[positionToRemove]["otherUserEmail"] as? String else { return }
                let otherSafeEmail = FirebaseManager.safeEmail(email: otherEmail)
                convs.remove(at: positionToRemove)
                self?.db.child(safeEmail).updateChildValues(["Conversations" : convs], withCompletionBlock: { err, _ in
                    if let err = err {
                        print(err)
                        completion(false)
                        print("Updating current user conversation failed")
                    } else {
                        self?.db.child("\(otherSafeEmail)/Conversations").observeSingleEvent(of: .value, with: { res in
                            if var otherUserConvs = res.value as? [[String: Any]] {
                                var otherUserConvPostition = 0
                                for conv in otherUserConvs {
                                    if let otherUserEmail = conv["otherUserEmail"] as? String, otherUserEmail == safeEmail {
                                        break
                                    } else {
                                        otherUserConvPostition += 1
                                    }
                                }
                                otherUserConvs.remove(at: otherUserConvPostition)
                                self?.db.child(otherSafeEmail).updateChildValues(["Conversations" : otherUserConvs], withCompletionBlock: { err, _ in
                                    if let err = err {
                                        print(err)
                                        completion(false)
                                        print("Updating other user conversation failed")
                                    } else {
                                        self?.db.child(conversationId).removeValue(completionBlock: { err, _ in
                                            guard err == nil else {
                                                completion(false)
                                                print("Deleting conversation failed")
                                                return
                                            }
                                            completion(true)
                                        })
                                    }
                                })
                            }
                        })
                    }
                })
            }
        })
    }
}

struct ChatAppUser {
    let name: String
    let surname: String
    let email: String
    
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePicFilename: String {
        let fileName = "\(safeEmail)_profile_picture.png"
        return fileName
    }
}
