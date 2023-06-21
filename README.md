# Дипломна робота
<br>Розробка мобільного додатку «Моя книгарня»
<br>«Кваліфікаційна робота на підтвердження ступеня фахового молодшого бакалавра (ВСП «ППФК НТУ «ХПІ») 
<br>Керівник роботи – Ірина Серебреннікова
<br>Студент - Владислав ПОСАШКОВ

## Завдання до дипломної роботи 
<br>Мобільний додаток є АІС, в якому буде реалізовано адміністративна та користувацька частина. В користувацькій частині має бути можливість пошуку книг та книжкових магазинів за фільтром, вибір типу сортування книг,  надсилання заявки на покупку чи обмін книги, редагування інформації на своєму профілі. В адміністративній частині має бути доступ до адміністрування кожного книжкового магазину окремо, додавання рекомендованих книг власником магазину, їх відображення на сторінці бібліотеки, а також рандомних книг рандомного жанру і останніх доданих, редагування інформації в профілі.
<br>Використати інструментарій: Swift, Firebase.

## Діаграма структури бази даних
<br><img width="460" alt="Screenshot 2023-06-16 at 12 35 59" src="https://github.com/vladdicckk/Bookstore/assets/92015183/676ec8d7-7f60-471a-ba08-09b9c4cc7c1d">

## Діаграма послідовності
<br><img width="503" alt="Screenshot 2023-06-16 at 12 38 39" src="https://github.com/vladdicckk/Bookstore/assets/92015183/784ebc23-3f5a-4258-a9cb-bb717ece1668">

## Вихідні коди
<br>Set required data and open chat with user
```
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let model = conversations?[indexPath.row] else { return }
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        let otherUserEmail = model.otherUserEmail
        var newOtherUserEmail = ""
        var counter = 0
        for ch in otherUserEmail {
            if ch == "-" {
                if counter == 0 {
                    newOtherUserEmail.append("@")
                } else {
                    newOtherUserEmail.append(".")
                }
                counter += 1
            } else {
                newOtherUserEmail.append(ch)
            }
        }
        firestoreManager.getUserInfo(email: newOtherUserEmail, completion: { [weak self] user in
            if user.email != "" {
                vc.otherUserData = user
                let path = "images.\(user.username)_Avatar.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] res in
                    switch res {
                    case .success(let res):
                        vc.chatUserImage = self?.chatUserImage
                        vc.chatProfileImageURL = res
                        URLSession.shared.dataTask(with: res) { (data, response, error) in
                            guard let data = data else { return }
                            DispatchQueue.main.async {
                                vc.chatOtherUserImage = UIImage(data: data)
                            }
                        }.resume()
                        self?.validateUserImage(completion: { img in
                            vc.chatUserImage = img
                            self?.navigationController?.pushViewController(vc, animated: true)
                        })
                    case .failure(let err):
                        print(err.localizedDescription)
                    }
                })
            } else {
                self?.firestoreManager.getBookstoreDataWithEmail(email: newOtherUserEmail, completion: { [weak self] bookstore in
                    if bookstore.email != "" {
                        vc.otherBookstoreData = bookstore
                        let path = "images.\(bookstore.name)_Avatar.png"
                        StorageManager.shared.downloadURL(for: path, completion: { [weak self] res in
                            switch res {
                            case .success(let res):
                                vc.chatUserImage = self?.chatUserImage
                                vc.chatProfileImageURL = res
                                URLSession.shared.dataTask(with: res) { (data, response, error) in
                                    guard let data = data else { return }
                                    DispatchQueue.main.async {
                                        vc.chatOtherUserImage = UIImage(data: data)
                                    }
                                }.resume()
                                self?.validateUserImage(completion: { img in
                                    vc.chatUserImage = img
                                    self?.navigationController?.pushViewController(vc, animated: true)
                                })
                            case .failure(let err):
                                print(err)
                            }
                        })
                    } else {
                        fatalError("2 types of user can`t be empty")
                    }
                })
            }
        })
    }
```
<br>Download current and other sender profile images
```
private func validateUserImage(completion: @escaping (UIImage) -> Void) {
        if let user = appDelegate().currentUser {
            let path = "images.\(user.username)_Avatar.png"
            StorageManager.shared.downloadURL(for: path, completion: { res in
                switch res {
                case .success(let res):
                    URLSession.shared.dataTask(with: res) { (data, response, error) in
                        guard let data = data else { return }
                        DispatchQueue.main.async {
                            guard let chatUserImage = UIImage(data: data) else { return }
                            completion(chatUserImage)
                        }
                    }.resume()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            })
        } else if let bookstore = appDelegate().currentBookstoreOwner {
            let path = "images.\(bookstore.name)_Avatar.png"
            StorageManager.shared.downloadURL(for: path, completion: { res in
                switch res {
                case .success(let res):
                    URLSession.shared.dataTask(with: res) { (data, response, error) in
                        guard let data = data else { return }
                        DispatchQueue.main.async {
                            guard let chatUserImage = UIImage(data: data) else { return }
                            completion(chatUserImage)
                        }
                    }.resume()
                case .failure(let err):
                    print(err.localizedDescription)
                }
            })
        }
    }
```
<br>Check is message from current sender or from other user
```
func isFromCurrentSender(message: MessageType) -> Bool {
        if FirebaseManager.safeEmail(email: message.sender.senderId) == otherUserEmail {
            return false
        } else {
            return true
        }
}
```
<br>Configuring user avatar
```
func configureAvatarView(_ avatarView: MessageKit.AvatarView, for message: MessageKit.MessageType, at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) {
        avatarImageCounter += 1
        guard avatarImageCounter <= 20 else { return }
        if isFromCurrentSender(message: message) {
            avatarView.image = chatUserImage
        } else {
            avatarView.image = chatOtherUserImage
        }
}
```
