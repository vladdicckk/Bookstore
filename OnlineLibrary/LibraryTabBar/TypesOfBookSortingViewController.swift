//
//  TypesOfBookSortingViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit

class TypesOfBookSortingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var greetingView: UIView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var sortTypes: [String] = ["Alphabet", "Genre", "Authors", "Year"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BooksTypeCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.textProperties.color = UIColor(red: 0.3, green: 0.1, blue: 0.2, alpha: 1)
        content.textProperties.font = .boldSystemFont(ofSize: 18)
        content.text = sortTypes[indexPath.row]
        
        cell.backgroundColor = .clear
        cell.contentConfiguration = content
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sortedBooksVC: SortedBooksInfoViewController = self.storyboard?.instantiateViewController(withIdentifier: "SortedBooksInfoViewController") as! SortedBooksInfoViewController
        self.navigationController?.pushViewController(sortedBooksVC, animated: true)
        //present(sortedBooksVC, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        mainView.backgroundColor = UIColor(patternImage: UIImage(named: "libraryBackground")!)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BooksTypeCell")
        mainViewProperties()
    }
    func mainViewProperties(){
        
        let backgroundMainViewBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.2
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = 16
            blurView.backgroundColor = UIColor.secondarySystemBackground
            blurView.clipsToBounds = true
            return blurView
        }()
        mainView.addSubview(backgroundMainViewBlur)
        mainView.sendSubviewToBack(backgroundMainViewBlur)
        NSLayoutConstraint.activate([
            backgroundMainViewBlur.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0),
            backgroundMainViewBlur.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 0),
            backgroundMainViewBlur.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0),
            backgroundMainViewBlur.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0)
        ])
        greetingViewProperties()
        tableViewProperties()
    }
    func greetingViewProperties(){
        greetingView.setCorner(radius: 16)
        greetingView.layer.borderWidth = 1
        greetingView.layer.borderColor = UIColor.black.cgColor
    }
    
func tableViewProperties(){
    let backgroundBlur: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.3
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.backgroundColor = UIColor.secondarySystemBackground
        blurView.clipsToBounds = true
        return blurView
    }()
    
    tableView.backgroundColor = .clear
    backgroundBlur.frame = self.tableView.bounds
    self.tableView.backgroundView = backgroundBlur
    
}
}
//if let containerView = additionalInfoTextView.superview {
//            let gradient = CAGradientLayer(layer: containerView.layer)
//            gradient.frame = containerView.bounds
//            gradient.colors = [UIColor.clear.cgColor, UIColor.blue.cgColor]
//            //the line above is update for swift 5
//            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
//            gradient.endPoint = CGPoint(x: 0.0, y: 0.85)
//            containerView.layer.mask = gradient
//        }
