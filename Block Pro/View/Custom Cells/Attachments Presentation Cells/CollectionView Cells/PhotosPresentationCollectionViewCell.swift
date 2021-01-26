//
//  PhotosPresentationCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 1/24/21.
//  Copyright © 2021 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class PhotosPresentationCollectionViewCell: UICollectionViewCell {
    
    let photoImageView = UIImageView()
    lazy var progressView: iProgressView = iProgressView(self, 100, .circleStrokeSpin)
    
    var iProgress: iProgressHUD?
    var showProgress: Bool = false
    
    let firebaseStorage = FirebaseStorage()
    
    var collabID: String?
    var blockID: String?
    var photoID: String?
    var photo: UIImage? {
        didSet {
                
            setPhoto(photo)
        }
    }
    
    var imageViewCornerRadius: CGFloat? {
        didSet {
            
            photoImageView.layer.cornerRadius = imageViewCornerRadius!
            photoImageView.layer.cornerCurve = .continuous
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureImageView()
        configureIProgressView()
        
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
        
            photoImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            photoImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            photoImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        
        ].forEach({ $0.isActive = true })
        
        photoImageView.backgroundColor = UIColor(hexString: "F4F4F4")?.darken(byPercentage: 0.1)
        
        photoImageView.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        photoImageView.layer.borderWidth = 1
        
        photoImageView.layer.cornerRadius = 8
        photoImageView.layer.cornerCurve = .continuous
        photoImageView.clipsToBounds = true
        
        photoImageView.contentMode = .scaleAspectFill
    }
    
    private func configureIProgressView () {
        
        self.contentView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false

        [

            progressView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            progressView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            progressView.widthAnchor.constraint(equalToConstant: 90),
            progressView.heightAnchor.constraint(equalToConstant: 90)

        ].forEach({ $0.isActive = true })
    }
    
    private func setPhoto (_ photo: UIImage?) {
        
        photoImageView.image = nil
        
        if let photo = photo {
            
            photoImageView.image = photo
        }
        
        else if let collabID = collabID, let blockID = blockID, let photoID = photoID {
            
            showProgress = true
            
            firebaseStorage.retrieveCollabBlockPhotoFromStorage(collabID, blockID, photoID) { (error, photo) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else {
                    
                    self.photoImageView.image = photo

                    self.showProgress = false
                    self.progressView.dismissProgress()

                    self.cachePhotoDelegate?.cacheBlockPhoto(photoID: photoID, photo: photo)
                }
            }
        }
        
        else if let collabID = collabID, let photoID = photoID {
            
            showProgress = true
            
            firebaseStorage.retrieveCollabPhotosFromStorage(collabID: collabID, photoID: photoID) { (photo, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else {
                    
                    self.photoImageView.image = photo
                    
                    self.showProgress = false
                    self.progressView.dismissProgress()
                    
                    self.cachePhotoDelegate?.cacheCollabPhoto(photoID: photoID, photo: photo)
                }
            }
        }
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
