//
//  Extension+UIView.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.01.2023.
//


import UIKit

extension UIView {
    func setCorner(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    func backgroundBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        
        blurView.alpha = 0.6
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 16
        blurView.backgroundColor = UIColor.clear
        blurView.clipsToBounds = true
        blurView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        blurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        blurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        blurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        
        addSubview(blurView)
        sendSubviewToBack(blurView)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat){
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

