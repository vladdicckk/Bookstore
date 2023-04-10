//
//  NewConversationViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//

import UIKit
import FirebaseDatabase

class NewConversationViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    private let db = Database.database().reference()
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    var emails: [String]?
    var completion: ((SearchResult) -> (Void))?
    private var hasFetched = false
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.text = "No results"
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.placeholder = "Search for users..."
        return searchbar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        view.addSubview(tableView)
        view.addSubview(noResultLabel)
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonTapped))
        tableView.register(NewConversationTableViewCell.self, forCellReuseIdentifier: "NewConversationTableViewCell")
        setupTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/4, width: 15, height: 20)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else { return }
        searchBar.resignFirstResponder()
        results.removeAll()
        searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        if hasFetched {
            filterUsers(with: query)
        } else {
            FirebaseManager.shared.getAllUsers(completion: { [weak self] res in
                switch res {
                case .failure(let err):
                    print(err)
                case .success(let res):
                    self?.users = res
                    self?.hasFetched = true
                    self?.filterUsers(with: query)
                }
            })
        }
    }
    
    func filterUsers(with term: String) {
        guard let currentUserEmail = appDelegate().currentEmail, let emails = emails, hasFetched else {
            return
        }
        let safeEmail = FirebaseManager.safeEmail(email: currentUserEmail)
        
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail, !emails.contains(email)  else { return false }
            guard let name = $0["name"]?.lowercased() as? String else { return false }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else { return nil }
            let username = $0["username"]
            
            return SearchResult(name: name, email: email, bookstoreName: "", username: username ?? "")
        })
        self.results = results
        updateUI()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewConversationTableViewCell", for: indexPath) as! NewConversationTableViewCell
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
        
        cell.backgroundView = backgroundBlur
        cell.selectedBackgroundView = cell.backgroundView
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.selectedBackgroundView?.layer.cornerRadius = 16
        cell.layer.cornerRadius = 16
        cell.backgroundColor = .clear
        cell.configure(with: model)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func updateUI() {
        if results.isEmpty {
            noResultLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultLabel.isHidden = true
            tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}

struct SearchResult {
    let name: String
    let email: String
    let bookstoreName: String
    let username: String
}

