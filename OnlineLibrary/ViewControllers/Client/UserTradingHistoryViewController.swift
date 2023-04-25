//
//  UserTradingHistoryViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 24.04.2023.
//

import UIKit

class UserTradingHistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tradingHistoryView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var arr: [ApplicationMainInfo]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TradingHistoryCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tradingHistoryView.backgroundColor = .clear
    }
    
    private func createLightBlurEffect(alpha: Double, view: UIView, clipsToBounds: Bool) {
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = alpha
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = clipsToBounds
            return blurView
        }()
        view.addSubview(backgroundBlur)
        view.sendSubviewToBack(backgroundBlur)

        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundBlur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            backgroundBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arr?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradingHistoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        guard let arr = arr else { return cell }
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.textProperties.font = UIFont.boldSystemFont(ofSize: 17)
        content.text = "Book title: \(arr[indexPath.row].book.title), Author: \(arr[indexPath.row].book.author)"
        if arr[indexPath.row].type != "" {
            if arr[indexPath.row].status {
                content.secondaryText = "\(arr[indexPath.row].type). Status: Success"
            } else {
                content.secondaryText = "\(arr[indexPath.row].type). Status: Failure"
            }
        } else {
            if arr[indexPath.row].status {
                content.secondaryText = "Status: Success"
            } else {
                content.secondaryText = "Status: Failure"
            }
        }
        
        let backgroundTableViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.8
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        tableView.backgroundView = backgroundTableViewBlur
        
        cell.backgroundColor = .clear
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.9
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = .clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor.systemBrown.cgColor
        cell.backgroundView = backgroundBlur
        cell.selectedBackgroundView?.backgroundColor = .clear
        cell.selectedBackgroundView?.layer.cornerRadius = 16
        cell.layer.cornerRadius = 16
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let arr = arr else { return }
        let vc: ApplicationViewController = storyboard?.instantiateViewController(withIdentifier: "ApplicationViewController") as! ApplicationViewController
        vc.application = arr[indexPath.row]
        vc.isTextViewMustBeHidden = true
        present(vc, animated: true)
    }
    
    override func updateViewConstraints() {
        view.frame.size.height = tableView.height
        view.frame.origin.y = 150
        view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
}
