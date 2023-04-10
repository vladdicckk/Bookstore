//
//  ChatViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//

import UIKit
import MessageKit
import CoreLocation
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import MapKit
import FirebaseStorage

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    var size: CGSize
}

class ChatViewController: MessagesViewController, MessageCellDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate , InputBarAccessoryViewDelegate, UIImagePickerControllerDelegate &  UINavigationControllerDelegate {
    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    var application: Application?
    let firestoreManager = FirestoreManager()
    var isNewConversation = false
    var otherUserEmail: String?
    var conversationId: String?
    var avatarImageCounter = 0
    var chatProfileImageURL: URL?
    
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let email = appDelegate().currentEmail else { return nil }
        let safeEmail = FirebaseManager.safeEmail(email: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        loadFirstMessages()
        setupInputButton()
        setupBackroundImage()
        messageInputBar.inputTextView.backgroundColor = .systemBrown
        messageInputBar.contentView.backgroundColor = .systemBrown
        messageInputBar.backgroundView.backgroundColor = .systemBrown
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        if let application = application {
            messageInputBar.inputTextView.text = "\(application.userInfo) \n\n Title: \(application.book.title) Author: \(application.book.author) Price: \(application.book.price) Publish year: \(application.book.publishYear) With preference: \(application.type) Additional info: \(application.additionalInfo) Created: \(application.date)"
            self.application = nil
        }
        activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let id = conversationId {
            listenForMessages(id: id, shouldScrollToBottom: true)
        }
        DispatchQueue.main.async {[weak self] in
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToLastItem()
        }
        messageInputBar.isHidden = false
        tabBarController?.tabBar.isHidden = true
    }
    
    private func setupBackroundImage() {
        messagesCollectionView.backgroundColor = .clear
        view.backgroundColor = .clear
        view.backgroundColor = UIColor(patternImage: UIImage(named: "chatsBackground") ?? UIImage())
        configureViewBlur()
        configureMessageInputBarBlur()
    }
    
    private func configureViewBlur() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.prominent)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.4
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        view.addSubview(backgroundBlur)
        view.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureMessageInputBarBlur() {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 1
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        messageInputBar.blurView = backgroundBlur
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Media", message: "What would you like to attach?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] _ in
            self?.messageInputBar.isHidden = false
        }))
        present(actionSheet, animated: true, completion: {[weak self] in
            self?.messageInputBar.resignFirstResponder()
            self?.messageInputBar.isHidden = true
        })
    }
    
    private func presentPhotoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Photo", message: "Where would you like attach a photo from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {[weak self] _ in
                    alert.dismiss(animated: true, completion: {[weak self] in
                        self?.messageInputBar.isHidden = false
                    })
                    self?.messagesCollectionView.reloadData()
                }))
                self?.present(alert, animated: true)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] _ in
            self?.messageInputBar.isHidden = false
            self?.messagesCollectionView.reloadData()
        }))
        present(actionSheet, animated: true, completion: {[weak self] in
            self?.messageInputBar.resignFirstResponder()
            self?.messageInputBar.isHidden = true
        })
    }
    
    private func presentVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: "Attach Video", message: "Where would you like attach a video from?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.mediaTypes = ["public.movie"]
                picker.videoQuality = .typeLow
                picker.allowsEditing = true
                self?.present(picker, animated: true)
            } else {
                let alert = UIAlertController(title: "Error", message: "Device has no camera", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {[weak self] _ in
                    alert.dismiss(animated: true, completion: {[weak self] in
                        self?.messageInputBar.isHidden = false
                    })
                    self?.messagesCollectionView.reloadData()
                }))
                self?.present(alert, animated: true)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Video library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] _ in
            self?.messageInputBar.isHidden = false
            self?.messagesCollectionView.reloadData()
        }))
        present(actionSheet, animated: true, completion: {[weak self] in
            self?.messageInputBar.resignFirstResponder()
            self?.messageInputBar.isHidden = true
        })
    }
    
    private func loadFirstMessages() {
        DispatchQueue.main.async {[weak self] in
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.scrollToLastItem(animated: false)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        FirebaseManager.shared.getAllMessangesForConversation(with: id, completion: { [weak self] res in
            switch res {
            case .success(let success):
                print("success getting messages: \(success)")
                guard !success.isEmpty else {
                    print("messages are empty")
                    self?.isNewConversation = true
                    return
                }
                self?.messages = success
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let failure):
                print(failure)
            }
        })
    }
    
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let currentUserEmail = appDelegate().currentEmail else { return }
        picker.dismiss(animated: true, completion: {[weak self] in
            self?.messageInputBar.isHidden = false
        })
        guard let convId = conversationId, let name = title, let otherUserEmail = otherUserEmail, let selfSender = selfSender, let imageId = createImageID()  else { return }
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage, let resizeImage = image.resizeWithWidth(width: 700), let compressionQuality = resizeImage.jpeg(.lowest) {
            
            let fileName = "photo_message_\(imageId).jpeg"
            
            StorageManager.shared.uploadMessagePhoto(with: compressionQuality, fileName: fileName, completion: { res in
                switch res {
                case .success(let url):
                    print(url)
                    guard let url = URL(string: url), let placeholderImage = UIImage(systemName: "plus") else { return }
                    let media = Media(url: url, placeholderImage: placeholderImage, size: .zero)
                    let message = Message(sender: selfSender, messageId: imageId, sentDate: Date(), kind: .photo(media))
                    FirebaseManager.shared.sendMessage(otherUserEmail: otherUserEmail, name: name, to: convId, message: message, email: currentUserEmail, completion: { [weak self]  res in
                        if res {
                            self?.messages.append(message)
                            self?.messagesCollectionView.reloadData()
                            print("Photo message sent successfully")
                        } else {
                            print("Failed to send photo message")
                        }
                    })
                case .failure(let err):
                    print("Message image upload failed: \(err)")
                }
            })
        } else if let videoUrl = info[.mediaURL] as? URL, let videoId = createVideoID() {
            let fileName = "video_message_\(videoId).movie"
            
            // Upload video
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { res in
                switch res {
                case .success(let url):
                    print(url)
                    guard let url = URL(string: url), let placeholderImage = UIImage(systemName: "plus") else { return }
                    let media = Media(url: url, placeholderImage: placeholderImage, size: .zero)
                    let message = Message(sender: selfSender, messageId: videoId, sentDate: Date(), kind: .video(media))
                    FirebaseManager.shared.sendMessage(otherUserEmail: otherUserEmail, name: name, to: convId, message: message, email: currentUserEmail, completion: {[weak self]  res in
                        if res {
                            self?.messages.append(message)
                            self?.messagesCollectionView.reloadData()
                            print("Video message sent successfully")
                        } else {
                            print("Failed to send video message")
                        }
                    })
                case .failure(let err):
                    print("Message video upload failed: \(err)")
                }
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {[weak self] in
            self?.messageInputBar.isHidden = false
        })
        messagesCollectionView.reloadData()
    }
    
    // TODO: Send messages in real time
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        print(text)
        
        guard let otherUserEmailNotSafe = otherUserEmail, let sender = selfSender, let messageID = createMessageID(), let id = createConversationID() else {
            print("failed sending message")
            return }
        let otherUserEmail = FirebaseManager.safeEmail(email: otherUserEmailNotSafe)
        let tempName: String?
        if appDelegate().currentUser != nil {
            tempName = "\(appDelegate().currentUser?.firstName ?? "") \(appDelegate().currentUser?.lastName ?? "")"
        } else {
            tempName = appDelegate().currentBookstoreOwner?.ownersName
        }
        guard let currentName = tempName else { return }
        
        guard let name = title, let currentEmail = appDelegate().currentEmail else {
            print("convId is Empty")
            return }
        
        let message = Message(sender: sender, messageId: messageID, sentDate: Date(), kind: .text(text))
        if isNewConversation {
            FirebaseManager.shared.createNewConversation(with: otherUserEmail, name: name, firstMessage: message, id: id, currentEmail: currentEmail, currentName: currentName, completion: { [weak self] res in
                if res {
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    print("Message sent")
                    self?.isNewConversation = false
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                } else {
                    print("Failed to send message")
                }
            })
        } else {
            print(" Not new conv ")
            guard let id = conversationId else { return }
            
            FirebaseManager.shared.sendMessage(otherUserEmail: otherUserEmail, name: name, to: id, message: message, email: currentEmail, completion: { success in
                if success {
                    print("Message sent")
                } else {
                    print("Failed to send")
                }
            })
        }
        messages.append(message)
        
        DispatchQueue.main.async {[weak self] in
            self?.messagesCollectionView.reloadData()
            self?.messagesCollectionView.reloadDataAndKeepOffset()
        }
        
        inputBar.inputTextView.text = ""
    }
    
    private func createConversationID() -> String? {
        guard let currentUserEmail = appDelegate().currentEmail else { return nil }
        guard let otherUserEmail = otherUserEmail else { return nil }
        let currentUserSafeEmail = FirebaseManager.safeEmail(email: currentUserEmail)
        let otherUserSafeEmail = FirebaseManager.safeEmail(email: otherUserEmail)
        let newID = "\(otherUserSafeEmail)_\(currentUserSafeEmail)"
        return newID
    }
    
    private func createMessageID() -> String? {
        Self.dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = appDelegate().currentEmail else { return nil }
        guard let otherUserEmail = otherUserEmail else { return nil }
        let currentUserSafeEmail = FirebaseManager.safeEmail(email: currentUserEmail)
        let otherUserSafeEmail = FirebaseManager.safeEmail(email: otherUserEmail)
        let newID = "\(otherUserSafeEmail)_\(currentUserSafeEmail)_\(dateString)"
        return newID
    }
    
    private func createImageID() -> String? {
        Self.dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = appDelegate().currentEmail else { return nil }
        guard let otherUserEmail = otherUserEmail else { return nil }
        let currentUserSafeEmail = FirebaseManager.safeEmail(email: currentUserEmail)
        let otherUserSafeEmail = FirebaseManager.safeEmail(email: otherUserEmail)
        let newID = "\(otherUserSafeEmail)_\(currentUserSafeEmail)_\(dateString)"
        return newID.replacingOccurrences(of: "-", with: "_")
    }
    
    private func createVideoID() -> String? {
        Self.dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let dateString = Self.dateFormatter.string(from: Date())
        guard let currentUserEmail = appDelegate().currentEmail else { return nil }
        guard let otherUserEmail = otherUserEmail else { return nil }
        let currentUserSafeEmail = FirebaseManager.safeEmail(email: currentUserEmail)
        let otherUserSafeEmail = FirebaseManager.safeEmail(email: otherUserEmail)
        let newID = "\(otherUserSafeEmail)_\(currentUserSafeEmail)_\(dateString)"
        return newID.replacingOccurrences(of: "-", with: "_")
    }
    
    func didTapBackground(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapMessage(in cell: MessageKit.MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    // TODO: open profile after tap avatar
    func didTapAvatar(in cell: MessageKit.MessageCollectionViewCell) {
        print("Avatar tapped")
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        guard var otherUserEmail = otherUserEmail else { return }
        var notSafeOtherUserEmail = ""
        var counter = 0
        for ch in otherUserEmail {
            if ch == "-" {
                if counter == 0 {
                    notSafeOtherUserEmail.append("@")
                } else {
                    notSafeOtherUserEmail.append(".")
                }
                counter += 1
            } else {
                notSafeOtherUserEmail.append(ch)
            }
        }
        otherUserEmail = notSafeOtherUserEmail
        
        if isFromCurrentSender(message: message) {
            if appDelegate().currentUser != nil {
                guard let email = appDelegate().currentEmail else { return }
                firestoreManager.getUserInfo(email: email, completion: { [weak self] user in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "ChatProfileViewController") as! ChatProfileViewController
                    vc.user = user
                    vc.chatProfileImageURL = self?.chatProfileImageURL
                    self?.present(vc, animated: true, completion: {[weak self] in
                        self?.messageInputBar.isHidden = true
                    })
                })
            } else {
                guard let email = appDelegate().currentEmail else { return }
                firestoreManager.getBookstoreDataWithEmail(email: email, completion: { [weak self] bookstore in
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "ChatProfileViewController") as! ChatProfileViewController
                    vc.bookstore = bookstore
                    vc.chatProfileImageURL = self?.chatProfileImageURL
                    self?.present(vc, animated: true, completion: {[weak self] in
                        self?.messageInputBar.isHidden = true
                    })
                })
            }
        } else {
            firestoreManager.getUserInfo(email: otherUserEmail, completion: { [weak self] user in
                if user.email != "" {
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
                    let vc = storyBoard.instantiateViewController(withIdentifier: "ChatProfileViewController") as! ChatProfileViewController
                    vc.user = user
                    vc.chatProfileImageURL = self?.chatProfileImageURL
                    self?.present(vc, animated: true, completion: {[weak self] in
                        self?.messageInputBar.isHidden = true
                    })
                } else {
                    self?.firestoreManager.getBookstoreDataWithEmail(email: otherUserEmail, completion: { bookstore in
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Chat", bundle: nil)
                        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatProfileViewController") as! ChatProfileViewController
                        vc.bookstore = bookstore
                        vc.chatProfileImageURL = self?.chatProfileImageURL
                        self?.present(vc, animated: true, completion: {[weak self] in
                            self?.messageInputBar.isHidden = true
                        })
                    })
                }
            })
        }
    }
    
    
    func didTapCellTopLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapCellBottomLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapMessageTopLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapMessageBottomLabel(in cell: MessageKit.MessageCollectionViewCell) {
        
    }
    
    func didTapAccessoryView(in cell: MessageKit.MessageCollectionViewCell) {
        print("AccessoryView tapped")
    }
    
    func didTapImage(in cell: MessageKit.MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoUrl = media.url else { return }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoUrl)
            present(vc, animated: true)
        default:
            break
        }
    }
    
    func didTapPlayButton(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func didStartAudio(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func didPauseAudio(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func didStopAudio(in cell: MessageKit.AudioMessageCell) {
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func backgroundColor(for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .blue
        } else {
            return .brown
        }
    }
    
    func isFromCurrentSender(message: MessageType) -> Bool {
        if FirebaseManager.safeEmail(email: message.sender.senderId) == otherUserEmail {
            return false
        } else {
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.section]
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            let vc = PhotoViewerViewController(with: imageUrl)
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            guard let url = media.url else { return }
            imageView.sd_setImage(with: url, completed: {  (image: UIImage?, error: Error?, cacheType: SDImageCacheType, imageURL: URL?) in
                imageView.image = image
                messagesCollectionView.reloadDataAndKeepOffset()
                print(error?.localizedDescription ?? "")
            })
        case .video(let media):
            print(media.url?.absoluteString ?? "")
        default:
            break
        }
    }
    
    func configureAvatarView(_ avatarView: MessageKit.AvatarView, for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) {
        sleep(1)
        avatarImageCounter += 1
        guard avatarImageCounter <= 400 else { return }
        guard var otherUserEmail = otherUserEmail else { return }
        var notSafeOtherUserEmail = ""
        var counter = 0
        for ch in otherUserEmail {
            if ch == "-" {
                if counter == 0 {
                    notSafeOtherUserEmail.append("@")
                } else {
                    notSafeOtherUserEmail.append(".")
                }
                counter += 1
            } else {
                notSafeOtherUserEmail.append(ch)
            }
        }
        otherUserEmail = notSafeOtherUserEmail
        
        if isFromCurrentSender(message: message) {
            if appDelegate().currentUser != nil {
                guard let email = appDelegate().currentEmail else { return }
                firestoreManager.getUserInfo(email: email, completion: { user in
                    let path = "images.\(user.username)_Avatar.png"
                    StorageManager.shared.downloadURL(for: path, completion: { [weak self] res in
                        switch res {
                        case .success(let res):
                            self?.chatProfileImageURL = res
                            DispatchQueue.global().async {
                                // Fetch Image Data
                                if let data = try? Data(contentsOf: res) {
                                    DispatchQueue.main.async {
                                        // Create Image and Update Image View
                                        avatarView.image = UIImage(data: data)
                                    }
                                }
                            }
                        case .failure(let err):
                            print(err)
                        }
                    })
                })
            } else {
                guard let email = appDelegate().currentEmail else { return }
                firestoreManager.getBookstoreDataWithEmail(email: email, completion: { bookstore in
                    let path = "images.\(bookstore.name)_Avatar.png"
                    StorageManager.shared.downloadURL(for: path, completion: { [weak self] res in
                        switch res {
                        case .success(let res):
                            self?.chatProfileImageURL = res
                            DispatchQueue.global().async {
                                // Fetch Image Data
                                if let data = try? Data(contentsOf: res) {
                                    DispatchQueue.main.async {
                                        // Create Image and Update Image View
                                        avatarView.image = UIImage(data: data)
                                    }
                                }
                            }
                        case .failure(let err):
                            print(err)
                        }
                    })
                })
            }
        } else {
            firestoreManager.getUserInfo(email: otherUserEmail, completion: { [weak self] user in
                let path = "images.\(user.username)_Avatar.png"
                if user.email != "" {
                    StorageManager.shared.downloadURL(for: path, completion: { [weak self] res in
                        switch res {
                        case .success(let res):
                            self?.chatProfileImageURL = res
                            DispatchQueue.global().async {
                                // Fetch Image Data
                                if let data = try? Data(contentsOf: res) {
                                    DispatchQueue.main.async {
                                        // Create Image and Update Image View
                                        avatarView.image = UIImage(data: data)
                                    }
                                }
                            }
                        case .failure(let err):
                            print(err.localizedDescription)
                        }
                    })
                } else {
                    self?.firestoreManager.getBookstoreDataWithEmail(email: otherUserEmail, completion: { bookstore in
                        let path = "images.\(bookstore.name)_Avatar.png"
                        StorageManager.shared.downloadURL(for: path, completion: { [weak self] res in
                            switch res {
                            case .success(let res):
                                self?.chatProfileImageURL = res
                                DispatchQueue.global().async {
                                    // Fetch Image Data
                                    if let data = try? Data(contentsOf: res) {
                                        DispatchQueue.main.async {
                                            // Create Image and Update Image View
                                            avatarView.image = UIImage(data: data)
                                        }
                                    }
                                }
                            case .failure(let err):
                                print(err)
                            }
                        })
                    })
                }
            })
        }
    }
    
//    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) {
//        guard let message = message as? Message else { return }
//        switch message.kind {
//        case .photo(let media):
//            guard let imageUrl = media.url else { return }
//            imageView.sd_setImage(with: imageUrl)
//        case .video(let media):
//            guard let imageUrl = media.url else { return }
//            imageView.sd_setImage(with: imageUrl)
//        default:
//            break
//        }
//    }
    
    func typingIndicatorViewTopInset(in messagesCollectionView: MessageKit.MessagesCollectionView) -> CGFloat {
        return 25
    }
    
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Sender empty")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func locationCellSetup(indexPath: IndexPath) {
        switch messages[indexPath.row].kind {
        case .location(let loc):
            let map = MKMapView()
            messagesCollectionView.addSubview(map)
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: loc.location.coordinate.latitude, longitude: loc.location.coordinate.longitude)
            map.addAnnotation(pin)
            guard let bounds = messagesCollectionView.cellForItem(at: indexPath)?.bounds else { return }
            map.frame = bounds
        default:
            break
        }
    }
    
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0.1
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: quality.rawValue)
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
