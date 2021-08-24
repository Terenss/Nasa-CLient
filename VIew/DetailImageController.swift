//
//  DetailImageController.swift
//  Nasa-Client
//
//  Created by Dmitrii on 12.08.2021.
//

import UIKit
import Kingfisher

class DetailImageController: UIViewController {
    
    var photoImageView: UIImageView!
    var roverLabel: UILabel!
    var cameraLabel: UILabel!
    var dateLabel: UILabel!
    var photoImageButton: UIButton!
    
    var photoModel: Photo?
    var image: String?
    
    var receivedPhotos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTheView()
        if let model = photoModel {
            setModelToUI(with: model)
        }
    }
    
    func configureTheView() {
        photoImageButton = UIButton()
        photoImageButton.translatesAutoresizingMaskIntoConstraints = false
        photoImageButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        view.addSubview(photoImageButton)
        photoImageView = UIImageView()
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: view.topAnchor),
            photoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200),
            photoImageButton.topAnchor.constraint(equalTo: view.topAnchor),
            photoImageButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photoImageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photoImageButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200)
            
        ])
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            roverLabel = UILabel(text: "", font: UIFont(name: "Helvetica", size: 20), textColor: .label, textAlignment: .left, numberOfLines: 1)
            view.addSubview(roverLabel)
            cameraLabel = UILabel(text: "", font: UIFont(name: "Helvetica", size: 20), textColor: .label, textAlignment: .left, numberOfLines: 1)
            view.addSubview(cameraLabel)
            dateLabel = UILabel(text: "", font: UIFont(name: "Helvetica", size: 20), textColor: .label, textAlignment: .left, numberOfLines: 1)
            view.addSubview(dateLabel)
        } else {
            // Fallback on earlier versions
        }
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.backgroundColor = .clear
        
        stackView.addArrangedSubview(roverLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(cameraLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
    
    @objc func buttonPressed(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let scrollImageViewController = storyboard.instantiateViewController(withIdentifier: "ScrollImageViewController") as? ScrollImageViewController {
            scrollImageViewController.photo = photoImageView.image
            self.navigationController?.pushViewController(scrollImageViewController, animated: true)
        }
        
    }
    
    public func setModelToUI(with model: Photo){
        self.roverLabel.text = "Rover: \(model.rover.name ?? "")"
        self.cameraLabel.text = "Camera: \(model.camera.fullName ?? "")"
        self.dateLabel.text = "Date: \(model.earthDate ?? "")"
        if let photoURL = URL(string: model.imagePath ?? "") {
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(with: photoURL)
        }
    }
}

