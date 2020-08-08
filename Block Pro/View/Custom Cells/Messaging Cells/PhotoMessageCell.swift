//
//  PhotoMessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/17/20.
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
    @IBOutlet var imageViewContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet var imageViewContainerLeadingAnchor: NSLayoutConstraint!
    @IBOutlet var imageViewContainerTrailingAnchor: NSLayoutConstraint!
    @IBOutlet var imageViewContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var iProgressView: UIView!
    
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
            
            configureProfilePic(message: message!)
            configureNameLabel(message: message!)
            configureImageViewContainer(message: message!)
            configureImageView(message: message!)
        }
    }
    
    weak var cachePhotoDelegate: CachePhotoProtocol?
    weak var zoomInDelegate: ZoomInProtocol?
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.3
        self.contentView.addGestureRecognizer(longPressGesture)
    }
    
    private func configureProfilePic (message: Message) {
        
        if message.sender == currentUser.userID {
            
            picContainerTopAnchor.constant = 3
            profilePicContainer.isHidden = true
            return
        }
        
        else if previousMessage?.sender == message.sender {
            
            if previousMessage?.memberJoiningConversation == nil && previousMessage?.memberUpdatedConversationCover == nil && previousMessage?.memberUpdatedConversationName == nil {
                
                picContainerTopAnchor.constant = 3
                profilePicContainer.isHidden = true
                return
            }
            
            else {
                
                picContainerTopAnchor.constant = 15
                profilePicContainer.isHidden = false
            }
        }
        
        else {
            
            picContainerTopAnchor.constant = 15
            profilePicContainer.isHidden = false
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
    
    private func configureNameLabel (message: Message?) {
        
        if message!.sender == currentUser.userID {
            
            nameLabel.isHidden = true
            return
        }
        
        else if previousMessage?.sender == message?.sender {
            
            if previousMessage?.memberJoiningConversation == nil && previousMessage?.memberUpdatedConversationCover == nil && previousMessage?.memberUpdatedConversationName == nil {
                
                nameLabel.isHidden = true
                return
            }
            
            else {
                
                nameLabel.isHidden = false
            }
        }
        
        else {
            
            nameLabel.isHidden = false
        }
        
        for member in members ?? [] {
            
            if member.userID == message?.sender {
                
                if members?.contains(where: { $0.firstName == member.firstName && $0.userID != member.userID}) ?? false {
                    
                    let lastInitial = Array(member.lastName)
                    
                    nameLabel.text = "\(member.firstName) \(lastInitial[0])."
                }
                
                else {
                    
                    nameLabel.text = member.firstName
                }
                
                break
            }
        }
    }
    
    private func configureImageViewContainer (message: Message) {
        
        guard let messagePhoto = message.messagePhoto else { return }
        
            imageViewContainerHeightConstraint.constant = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
        
            imageViewContainer.layer.cornerRadius = 10
            imageViewContainer.clipsToBounds = true
            
            if #available(iOS 13.0, *) {
                imageViewContainer.layer.cornerCurve = .continuous
            }
        
            if message.sender == currentUser.userID {
                
                imageViewContainerTopAnchor.constant = 0
                
                imageViewContainerLeadingAnchor.isActive = false
                
                imageViewContainerTrailingAnchor.isActive = true
            }
            
            else {
                
                if previousMessage?.sender == message.sender {
                    
                    if previousMessage?.memberJoiningConversation == nil && previousMessage?.memberUpdatedConversationCover == nil && previousMessage?.memberUpdatedConversationName == nil {
                        
                        imageViewContainerTopAnchor.constant = 0
                    }
                    
                    else {
                        
                       imageViewContainerTopAnchor.constant = 15
                    }
                }
                
                else {
                    
                    imageViewContainerTopAnchor.constant = 15
                }
                
                imageViewContainerTrailingAnchor.isActive = false
                
                imageViewContainerLeadingAnchor.constant = 10
                imageViewContainerLeadingAnchor.isActive = true
            }
    }
    
    private func configureImageView (message: Message) {
        
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
        
        imageViewContainer.backgroundColor = UIColor(hexString: "F4F4F4")?.darken(byPercentage: 0.1)
        
        iProgressView.isHidden = false
        
        configureProgressHUD()
        
        iProgressView.showProgress()
    }
    
    private func calculatePhotoMessageCellHeight (messagePhoto: [String : Any]) -> CGFloat {
        
        let photoWidth = messagePhoto["photoWidth"] as! CGFloat
        let photoHeight = messagePhoto["photoHeight"] as! CGFloat
        let height = (photoHeight / photoWidth) * 200
        
        return height
    }
    
    @objc private func handleZoomIn (tapGesture: UITapGestureRecognizer) {
        
        if let imageView = tapGesture.view as? UIImageView {
            
            zoomInDelegate?.zoomInOnPhotoImageView(photoImageView: imageView)
        }
    }
    
    @objc func handleLongPress (gesture: UILongPressGestureRecognizer) {
        
        let pressedLocation = gesture.location(in: self.contentView)
        let photoImageViewLocation = photoImageView.superview?.convert(photoImageView.frame, to: self)
        
        if gesture.state == .began {
            
            if photoImageViewLocation?.contains(pressedLocation) ?? false {
                
                let pasteboard = UIPasteboard.general
                pasteboard.image = photoImageView.image
                
                imageViewContainer.performCopyAnimationOnView()
                
                presentCopiedAnimationDelegate?.presentCopiedAnimation()
            }
        }
    }
}
