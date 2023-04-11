//
//  FilterByViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 17.01.2023.
//

import UIKit
import FirebaseFirestore

protocol SortByResultTypeProtocol {
    func sortNamesBy(type: String, location: String, preference: String)
}

class FilterByViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Parameters
    let filterTypeArr = ["Filter by location", "Sort by alphabet", "Filter by preference"]
    var db = Firestore.firestore()
    var location: String = ""
    var isLocationSelected: Bool?
    var delegate: SortByResultTypeProtocol?
    
    // MARK: Lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        mainViewProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dismissAfterChoosingLocation()
    }
    
    // MARK: Public and private functions
    private func dismissAfterChoosingLocation() {
        guard let isLocationSelected = isLocationSelected else { return }
        if isLocationSelected {
            dismiss(animated: true)
        }
    }
    
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
    
    private func getBookstoresLocations( _ completion: @escaping (_ success: Bool, _ arr: [String]) -> Void) {
        db.collection("Owners").getDocuments(completion: { res, err in
            if err != nil {
                completion(false, [])
            }
            var locationsArr: [String] = []
            
            for document in res!.documents {
                locationsArr.append("\(document.get("location") ?? "")")
            }
            
            locationsArr = locationsArr.filter { $0 != "" }
            locationsArr = locationsArr.unique()
            
            if locationsArr != [] {
                completion(true, locationsArr)
            } else {
                completion(false, [])
            }
        })
    }
    
    override func updateViewConstraints() {
        view.frame.size.height = tableView.height
        view.frame.origin.y = 150
        view.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10.0)
        super.updateViewConstraints()
    }
    
    // MARK: UITableViewDelegate and UITableViewDataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTypeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = filterTypeArr[indexPath.row]
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
        if indexPath.row == 0 {
            if delegate != nil {
                let locationSortVC: SortByLocationViewController = storyboard?.instantiateViewController(withIdentifier: "SortByLocationViewController") as! SortByLocationViewController
                getBookstoresLocations({[weak self]  success, arr in
                    if success {
                        locationSortVC.locationsArr = arr
                        locationSortVC.delegate = self?.delegate
                        self?.present(locationSortVC, animated: true)
                    }
                })
            }
        }
        if indexPath.row == 1 {
            if delegate != nil {
                delegate?.sortNamesBy(type: filterTypeArr[indexPath.row], location: "", preference: "")
                dismiss(animated: true)
            }
        }
            
        if indexPath.row == 2 {
            if delegate != nil {
                let preferenceVC: FilterByPreferenceViewController = self.storyboard?.instantiateViewController(withIdentifier: "FilterByPreferenceViewController") as! FilterByPreferenceViewController
                preferenceVC.delegate = self.delegate
                present(preferenceVC, animated: true)
            }
        }
    }
}

