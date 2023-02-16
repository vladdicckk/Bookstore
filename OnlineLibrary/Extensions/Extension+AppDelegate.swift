//
//  Extension+AppDelegate.swift
//  OnlineLibrary
//
//  Created by iosdev on 06.02.2023.
//

import UIKit

extension UIViewController{
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
}
