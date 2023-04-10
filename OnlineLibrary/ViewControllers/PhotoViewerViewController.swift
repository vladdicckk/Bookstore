//
//  PhotoViewerViewController.swift
//  OnlineLibrary
//
//  Created by iosdev on 05.04.2023.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {
    private let url: URL
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var viewHeight: CGFloat? {
        didSet {
            view.frame.size.height = viewHeight ?? view.frame.size.height
            imageView.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo"
        view.backgroundColor = .black
        navigationItem.largeTitleDisplayMode = .never
        tabBarController?.tabBar.isHidden = true
        view.addSubview(imageView)
        imageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(dismissPhotoViewer)))
        imageView.sd_setImage(with: url)
    }
    
    @objc func dismissPhotoViewer() {
        dismiss(animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
    }
    
    init(with url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

