//
//  ScrollImageViewController.swift
//  Nasa-Client
//
//  Created by Dmitrii on 21.08.2021.
//

import UIKit
import Kingfisher

class ScrollImageViewController: UIViewController {
    
    private var imageScrollView: ImageScrollView?
    
    public var photo: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageScrollView = ImageScrollView(frame: self.view.bounds)
        self.view.addSubview(imageScrollView!)
        
        imageScrollView?.set(image: photo ?? UIImage())
        self.setupImageScrollView()
        self.centerImage()
    }
    
    fileprivate func setupImageScrollView() {
        imageScrollView?.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView?.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
        imageScrollView?.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        imageScrollView?.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        imageScrollView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        imageScrollView?.center = self.view.center
        imageScrollView?.contentMode = .redraw
    }
    fileprivate func centerImage() {
        self.imageScrollView?.zoom(
            to: CGRect(
                origin: CGPoint(
                    x: self.imageScrollView!.contentSize.width / 2 - self.view.frame.size.width / 2,
                    y: self.imageScrollView!.contentSize.height / 2 - self.view.frame.size.height / 2 ),
                size: CGSize(width: 200, height: 200)), animated: false)
        self.imageScrollView?.setZoomScale(1, animated: true)
    }
}
