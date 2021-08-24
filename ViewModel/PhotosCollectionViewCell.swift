//
//  PhotosCollectionViewCell.swift
//  Nasa-Client
//
//  Created by Dmitrii on 11.08.2021.
//

import UIKit
import Kingfisher

class PhotosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    private var photoModel: Photo?
    
    
    public func setModelToUI(with model: Photo){
        if let photoURL = URL(string: model.imagePath ?? "") {
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: photoURL)
        }
    }
}
