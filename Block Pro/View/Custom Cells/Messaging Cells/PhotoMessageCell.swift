//
//  PhotoMessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/5/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import iProgressHUD

protocol CachePhotoProtocol: AnyObject {
    
    func cachePhoto (messageID: String, photo: UIImage?)
}

protocol ZoomInProtocol: AnyObject {
    
    func zoomInOnPhotoImageView (photoImageView: UIImageView)
}

class PhotoMessageCell: UITableViewCell {

    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var picContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageViewContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainerLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainerTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var imageViewContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var iProgressView: UIView!
    
    @IBOutlet weak var messageBubbleView: UIView!
    @IBOutlet weak var messageBubbleLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var textViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var textViewTrailingAnchor: NSLayoutConstraint!
    
    var iProgress: iProgressHUD?
    var iProgressAttached: Bool = false
    
    let currentUser = CurrentUser.sharedInstance
    var conversationID: String?
    var collabID: String?
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var members: [Member]?
    
    var previousMessage: Message?
    var message: Message? {
        didSet {
            
            configureCell(message: message!)
            configureProfilePic(message: message!)
            configureNameLabel(message: message!)
            configureImageView(message: message!)
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var zoomInDelegate: ZoomInProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageBubbleView.layer.cornerRadius = 10
        imageViewContainer.layer.cornerRadius = 10
        imageViewContainer.clipsToBounds = true
        
        if #available(iOS 13.0, *) {
            messageBubbleView.layer.cornerCurve = .continuous
            imageViewContainer.layer.cornerCurve = .continuous
        }
        
        messageTextView.backgroundColor = .clear
        
        //iProgressView.backgroundColor = .clear
    }
    
    private func configureCell (message: Message) {
        
        if let messageText = message.message {
            
//            textViewLeadingAnchor.isActive = true
//            textViewTrailingAnchor.isActive = true
            messageBubbleView.isHidden = false
            messageBubbleWidthConstraint.constant = messageText.estimateFrameForMessageCell().width + 30
            messageTextView.text = messageText
        }
        
        else {
            
//            textViewLeadingAnchor.isActive = false
//            textViewTrailingAnchor.isActive = false
            messageBubbleView.isHidden = true
            messageTextView.text = ""
        }
        
        if message.sender != currentUser.userID {
            
            imageViewContainerTrailingAnchor.isActive = false
            messageBubbleTrailingAnchor.isActive = false
            
            imageViewContainerLeadingAnchor.constant = 10
            messageBubbleLeadingAnchor.constant = 10
            
            imageViewContainerLeadingAnchor.isActive = true
            messageBubbleLeadingAnchor.isActive = true
            
            messageBubbleView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.50)
            messageTextView.textColor = .black
        }
        
        else {
            
            imageViewContainerLeadingAnchor.isActive = false
            messageBubbleLeadingAnchor.isActive = false
            
            imageViewContainerTrailingAnchor.isActive = true
            messageBubbleTrailingAnchor.isActive = true
            
            messageBubbleView.backgroundColor = UIColor(hexString: "282828", withAlpha: 0.85)
            messageTextView.textColor = .white
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            let numberOfLines = ((self.messageTextView.frame.height - 15) / self.messageTextView.font!.lineHeight)

            if floor(numberOfLines) == 1 {

                self.messageTextView.textAlignment = .center
            }

            else {

                self.messageTextView.textAlignment = .left
            }
        }
    }
    
    private func configureProfilePic (message: Message) {
        
        if previousMessage?.sender == message.sender {
            
            profilePicContainer.isHidden = true
            nameLabel.isHidden = true
            return
        }
        
        else {
            
            nameLabel.isHidden = false
            //imageViewTopAnchor.constant = 15
        }
        
        if members != nil {
            
            if message.sender != currentUser.userID {
                
                for member in members! {
                    
                    if member.userID == message.sender {
                        
                        profilePicContainer.configureProfilePicContainer(shadowRadius: 2)
                        
                        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == member.userID }) {
                            
                            profilePicImageView.configureProfileImageView(profileImage: firebaseCollab.friends[friendIndex].profilePictureImage)
                        }
                        
                        else {
                            
                            if firebaseCollab.membersProfilePics[member.userID] != nil {

                                profilePicImageView.configureProfileImageView(profileImage: firebaseCollab.membersProfilePics[member.userID]!)
                            }

                            else {

                                firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                                    
                                    self.profilePicImageView.configureProfileImageView(profileImage: profilePic)
                                        
                                    self.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: profilePic)
                                }
                            }
                        }
                    }
                }
                
                profilePicContainer.isHidden = false
            }
            
            else {
                
                profilePicContainer.isHidden = true
            }
        }
        
        else {
            
            profilePicContainer.isHidden = true
        }
    }
    
    private func configureNameLabel (message: Message) {
        
        if previousMessage?.sender == message.sender {
            
            nameLabel.isHidden = true
            picContainerTopAnchor.constant = 3
            //messageBubbleTopAnchor.constant = 0
            imageViewContainerTopAnchor.constant = 0
        }
            
        else if message.sender == currentUser.userID {
            
            nameLabel.isHidden = true
            picContainerTopAnchor.constant = 3
            //messageBubbleTopAnchor.constant = 0
            imageViewContainerTopAnchor.constant = 0
        }
        
        else {
            
            nameLabel.isHidden = false
            picContainerTopAnchor.constant = 15
            //messageBubbleTopAnchor.constant = 15
            imageViewContainerTopAnchor.constant = 15
            
            for member in members ?? [] {
                
                if member.userID == message.sender {
                    
                    let lastInitial = Array(member.lastName)
                    
                    nameLabel.text = "\(member.firstName) \(lastInitial[0])."
                }
            }
        }
    }
    
    func configureImageView (message: Message) {
        
        guard let messagePhoto = message.messagePhoto else { return }
       
            imageViewContainerHeightConstraint.constant = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)

            photoImageView.isUserInteractionEnabled = false
            photoImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomIn)))
            
        
            if let photo = message.messagePhoto?["photo"] as? UIImage {
                
                photoImageView.image = photo
                photoImageView.isUserInteractionEnabled = true
                
                iProgressView.isHidden = true
            }
            
            else if let photoID = message.messagePhoto?["photoID"] as? String {
                
                photoImageView.image = nil
                
                configureLoadingPhotoIndicator()
                
                if let conversation = conversationID {
                    
                    firebaseStorage.retrievePersonalMessagePhoto(conversationID: conversation, photoID: photoID) { (photo, error) in

                        if error != nil {

                            print(error as Any)
                        }

                        else {

                            self.photoImageView.image = photo
                            self.photoImageView.isUserInteractionEnabled = true
                            
                            self.imageViewContainer.backgroundColor = .white
                            self.iProgressView.dismissProgress()
                            self.iProgressView.isHidden = true

                            self.cachePhotoDelegate?.cachePhoto(messageID: message.messageID, photo: photo)
                        }
                    }
                }
                
                else if let collab = collabID {
                    
                    firebaseStorage.retrieveCollabMessagePhoto(collabID: collab, photoID: photoID) { (photo, error) in
                        
                        if error != nil {
                            
                            print(error as Any)
                        }
                        
                        else {
                            
                            self.photoImageView.image = photo
                            self.photoImageView.isUserInteractionEnabled = true
                            
                            self.imageViewContainer.backgroundColor = .white
                            self.iProgressView.dismissProgress()
                            self.iProgressView.isHidden = true
                            
                            self.cachePhotoDelegate?.cachePhoto(messageID: message.messageID, photo: photo)
                        }
                    }
                }
            }
    }
    
    private func calculatePhotoMessageCellHeight (messagePhoto: [String : Any]) -> CGFloat {
        
        let photoWidth = messagePhoto["photoWidth"] as! CGFloat
        let photoHeight = messagePhoto["photoHeight"] as! CGFloat
        let height = (photoHeight / photoWidth) * 200
        
        return height
    }
    
    private func configureLoadingPhotoIndicator () {
        
        imageViewContainer.backgroundColor = UIColor(hexString: "F4F4F4")?.darken(byPercentage: 0.1)
        
        iProgressView.isHidden = false
        
        configureProgressHUD()
        
        iProgressView.showProgress()
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
    
    @objc private func handleZoomIn (tapGesture: UITapGestureRecognizer) {
        
        if let imageView = tapGesture.view as? UIImageView {
            
            zoomInDelegate?.zoomInOnPhotoImageView(photoImageView: imageView)
        }
    }
}
