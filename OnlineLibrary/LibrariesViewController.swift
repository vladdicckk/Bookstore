//
//  LibrariesViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//

import UIKit

class LibrariesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var mainLibrariesView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LibraryCell")
        tableView.backgroundColor = .clear
        mainLibrariesViewSettings()
        for view in searchBar.subviews.last!.subviews {
            if type(of: view) == NSClassFromString("UISearchBarBackground"){
                view.alpha = 0.0
            }
        }
    }
    
    // MARK: Private functions
    private func mainLibrariesViewSettings() {
        mainLibrariesView.backgroundColor = .clear
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.5
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 14
            blurView.backgroundColor = UIColor.clear
            blurView.clipsToBounds = true
            return blurView
        }()
        
        mainLibrariesView.backgroundColor = UIColor(patternImage: UIImage(named: "librariesBackground")!)
        mainLibrariesView.addSubview(backgroundBlur)
        mainLibrariesView.sendSubviewToBack(backgroundBlur)
        backgroundBlur.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundBlurConstraints(blur: backgroundBlur)
    }
    
    private func backgroundBlurConstraints(blur: UIVisualEffectView) {
        blur.topAnchor.constraint(equalTo: mainLibrariesView.topAnchor, constant: 0).isActive = true
        blur.leadingAnchor.constraint(equalTo: mainLibrariesView.leadingAnchor, constant: 0).isActive = true
        blur.trailingAnchor.constraint(equalTo: mainLibrariesView.trailingAnchor, constant: 0).isActive = true
        blur.bottomAnchor.constraint(equalTo: mainLibrariesView.bottomAnchor, constant: 0).isActive = true
    }
    
    // MARK: Actions
    @IBAction func filterButtonTapped(_ sender: Any) {
        let filterVC: FilterByViewController = storyboard?.instantiateViewController(withIdentifier: "FilterByViewController") as! FilterByViewController
        present(filterVC, animated: true)
    }
    
    // MARK: UITableViewDataSource & UITableViewDelegate functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LibraryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.textProperties.font = .boldSystemFont(ofSize: 22)
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.text = "Library \(indexPath.row)"
        
        cell.backgroundColor = .clear
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tabBC: UITabBarController = self.storyboard?.instantiateViewController(withIdentifier: "LibraryTabBarController") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = tabBC
    }
}

