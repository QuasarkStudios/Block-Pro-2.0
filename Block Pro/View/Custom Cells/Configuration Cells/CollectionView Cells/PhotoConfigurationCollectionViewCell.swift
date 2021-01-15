//
//  PhotoConfigurationCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/13/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit

class PhotoConfigurationCollectionViewCell: UICollectionViewCell {
    
    let photoImageView = UIImageView()
    
    var photoID: String?
    var photo: UIImage? {
        didSet {
            
            photoImageView.image = photo
        }
    }
    
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureImageView()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView () {
        
        self.contentView.addSubview(photoImageView)
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            photoImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0),
            photoImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0),
            photoImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
            photoImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0)
        
        ].forEach({ $0.isActive = true })
        
        photoImageView.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        photoImageView.layer.borderWidth = 1
        
        photoImageView.layer.cornerRadius = 8
        photoImageView.layer.cornerCurve = .continuous
        photoImageView.clipsToBounds = true
        
        photoImageView.contentMode = .scaleAspectFill
    }
    
    @objc func handleLongPress (gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            
            let pasteboard = UIPasteboard.general
            pasteboard.image = photoImageView.image
            
            photoImageView.performCopyAnimationOnView()
            
            presentCopiedAnimationDelegate?.presentCopiedAnimation()
        }
    }
}
