//
//  LibrariesViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit

class LibrariesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var mainLibrariesView: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
        
        
        cell.backgroundColor = .clear
       // cell.backgroundView = backgroundBlur
        
        var content = cell.defaultContentConfiguration()
        content.textProperties.font = .boldSystemFont(ofSize: 22)
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.text = "Library \(indexPath.row)"
        
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tabBC: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = tabBC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LibraryCell")
        mainLibrariesView.backgroundColor = UIColor(patternImage: UIImage(named: "librariesBackground")!)
        tableView.backgroundColor = .clear
        for view in searchBar.subviews.last!.subviews {
            if type(of: view) == NSClassFromString("UISearchBarBackground"){
                view.alpha = 0.0
            }
        }
        mainLibrariesView.addSubview(backgroundBlur)
        mainLibrariesView.sendSubviewToBack(backgroundBlur)
        backgroundBlurConstraints()
        
    }
    func backgroundBlurConstraints() {
        backgroundBlur.topAnchor.constraint(equalTo: mainLibrariesView.topAnchor, constant: 0).isActive = true
        backgroundBlur.leadingAnchor.constraint(equalTo: mainLibrariesView.leadingAnchor, constant: 0).isActive = true
        backgroundBlur.trailingAnchor.constraint(equalTo: mainLibrariesView.trailingAnchor, constant: 0).isActive = true
        backgroundBlur.bottomAnchor.constraint(equalTo: mainLibrariesView.bottomAnchor, constant: 0).isActive = true
    }
    let backgroundBlur: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.3
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 14
        blurView.backgroundColor = UIColor.secondarySystemBackground
        blurView.clipsToBounds = true
        return blurView
    }()
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let filterVC: FilterByViewController = storyboard?.instantiateViewController(withIdentifier: "FilterByViewController") as! FilterByViewController
        present(filterVC, animated: true)
    }
}

