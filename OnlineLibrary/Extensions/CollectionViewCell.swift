//
//  CollectionViewCell.swift
//  OnlineLibrary
//
//  Created by iosdev on 11.01.2023.
//

import UIKit

extension UICollectionViewCell{
    
    func cellContentViewBackgroundBlur(cell: UICollectionViewCell, radius: Double) -> UIVisualEffectView{
        let backgroundBlur: UIVisualEffectView = {
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.alpha = 0.25
            blurView.translatesAutoresizingMaskIntoConstraints = false
            blurView.layer.cornerRadius = radius
            blurView.backgroundColor = UIColor.secondarySystemBackground
            blurView.clipsToBounds = true
            return blurView
        }()
        return  backgroundBlur
    }
}
