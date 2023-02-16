//
//  SortByLocationViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.02.2023.
//

import UIKit
import FirebaseFirestore


class SortByLocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    var locationsArr: [String]?
    var delegate: SortByResultTypeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        tableView.backgroundColor = .clear
        mainViewProperties()
    }
    
    // MARK: Public and private functions
    private func mainViewProperties() {
        view.backgroundColor = .clear
        
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.95
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
            backgroundBlur.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            backgroundBlur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            backgroundBlur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            backgroundBlur.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    override func updateViewConstraints() {
        self.view.frame.size.height = UIScreen.main.bounds.height - 600
        self.view.frame.origin.y = 150
        self.view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationsArr?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = locationsArr?[indexPath.row]
        content.textProperties.color = .brown
        
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
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let locationsArr = locationsArr else { return }
        
        let librariesVC: LibrariesViewController = self.storyboard?.instantiateViewController(withIdentifier: "LibrariesViewController") as! LibrariesViewController
        self.delegate?.sortNamesBy(type: "Filter by location", location: locationsArr[indexPath.row], preference: "")
        self.dismissTo(vc: librariesVC, count: 2, animated: true)
    }
}


