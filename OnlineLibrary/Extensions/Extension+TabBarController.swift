//
//  Extension+TabBarController.swift
//  OnlineLibrary
//
//  Created by iosdev on 10.01.2023.
//

import UIKit

extension UITabBar{
    func backgroundTabBarBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.4
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.backgroundColor = UIColor.secondarySystemBackground
        blurView.clipsToBounds = true
        blurView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        addSubview(blurView)
        sendSubviewToBack(blurView)
    }
}
