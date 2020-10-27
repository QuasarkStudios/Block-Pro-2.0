//
//  ConvoPhotoCollectionViewCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/10/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

class ConvoPhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var iProgressView: UIView!
    
    var iProgress: iProgressHUD?
    var iProgressAttached: Bool = false
    
    let firebaseStorage = FirebaseStorage()
    
    var conversationID: String?
    var collabID: String?
    
    var message: Message? {
        didSet {
            
            configureImageView(message: message!)
        }
    }
    
    var imageViewCornerRadius: CGFloat? {
        didSet {
            
            imageView.layer.cornerRadius = imageViewCornerRadius!
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.borderColor = UIColor(hexString: "D8D8D8")?.cgColor
        imageView.layer.borderWidth = 1
        
        if #available(iOS 13.0, *) {
            imageView.layer.cornerCurve = .continuous
        }
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGesture)
    }
    
    private func configureImageView (message: Message) {
        
        imageView.image = nil
        
        guard let messagePhoto = message.messagePhoto else { return }
        
            if let photo = messagePhoto["photo"] as? UIImage {
                
                imageView.image = photo
                
                iProgressView.isHidden = true
            }
            
            else if let photoID = messagePhoto["photoID"] as? String {
                
                imageView.image = nil
                
                configureLoadingPhotoIndicator()
                
                if let conversation = conversationID {
                    
                    firebaseStorage.retrievePersonalMessagePhoto(conversationID: conversation, photoID: photoID) { (photo, error) in
                        
                        if error != nil {
                            
                            print(error as Any)
                        }
                        
                        else {
                            
                            self.imageView.image = photo
                            
                            self.iProgressView.dismissProgress()
                            self.iProgressView.isHidden = true
                            
                            self.cachePhotoDelegate?.cacheMessagePhoto(messageID: message.messageID, photo: photo)
                        }
                    }
                }
                
                else if let collab = collabID {
                    
                    firebaseStorage.retrieveCollabMessagePhoto(collabID: collab, photoID: photoID) { (photo, error) in
                        
                        self.imageView.image = photo
                        
                        self.iProgressView.dismissProgress()
                        self.iProgressView.isHidden = true
                        
                        self.cachePhotoDelegate?.cacheMessagePhoto(messageID: message.messageID, photo: photo)
                    }
                }
            }
    }
    
    private func configureProgressHUD () {
        
        if !iProgressAttached {
            
            iProgressView.backgroundColor = .clear
            
            iProgress = iProgressHUD()
            
            iProgress?.isShowModal = false
            iProgress?.isShowCaption = false
            iProgress?.isTouchDismiss = false
            iProgress?.boxColor = .clear
            
            iProgress?.indicatorSize = 100
            
            iProgress?.attachProgress(toView: iProgressView)
            
            iProgressView.updateIndicator(style: .circleStrokeSpin)
            
            iProgressAttached = true
        }
    }
    
    private func configureLoadingPhotoIndicator () {
        
        imageView.backgroundColor = UIColor(hexString: "F4F4F4")?.darken(byPercentage: 0.1)
        
        iProgressView.isHidden = false
        
        configureProgressHUD()
        
        iProgressView.showProgress()
    }
    
    @objc func handleLongPress (gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .began {
            
            let pasteboard = UIPasteboard.general
            pasteboard.image = imageView.image
            
            imageView.performCopyAnimationOnView()
            
            presentCopiedAnimationDelegate?.presentCopiedAnimation()
        }
    }
}
