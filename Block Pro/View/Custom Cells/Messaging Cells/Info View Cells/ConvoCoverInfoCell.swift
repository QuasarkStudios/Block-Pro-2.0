//
//  ConvoPhotoInfoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/27/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

class ConvoCoverInfoCell: UITableViewCell {

    @IBOutlet weak var ovalBackgroundView: UIView!
    @IBOutlet weak var ovalBackgroundBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var backgroundImageViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var coverPhotoContainer: UIView!
    @IBOutlet weak var coverContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var coverContainerBottomAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var coverPhotoImageView: UIImageView!
    
    @IBOutlet weak var coverPhotoLabel: UILabel!
    @IBOutlet weak var photoLabelHeightConstraint: NSLayoutConstraint!
    
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var personalConversation: Conversation? {
        didSet {
            
            if conversationMember == nil {
                
                verifyCoverPhoto(personalConversation: personalConversation)
            }
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            verifyCoverPhoto(collabConversation: collabConversation)
        }
    }
    
    var conversationMember: Member? {
        didSet {

            retrieveProfilePic(member: conversationMember!)
        }
    }
    
    var visualEffectView = UIVisualEffectView(effect: nil)
    var animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.bringSubviewToFront(coverPhotoContainer)
        
        ovalBackgroundView.backgroundColor = UIColor(hexString: "222222")
        ovalBackgroundView.layer.cornerRadius = 0.5 * ovalBackgroundView.frame.width
        ovalBackgroundView.clipsToBounds = true
        
        backgroundImageViewWidthConstraint.constant = UIScreen.main.bounds.width
        
        self.ovalBackgroundView.addSubview(visualEffectView)
        configureVisualEffect()
    }
    
    private func verifyCoverPhoto (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
        
        if let conversation = personalConversation {
            
            if conversation.coverPhotoID != nil {
                
                if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                    
                    if let cover = firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto {
                        
                        configureCover(cover)
                    }
                    
                    else {
                        
                        firebaseStorage.retrievePersonalConversationCoverPhoto(conversationID: conversation.conversationID) { (cover, error) in
                            
                            if error != nil {
                                
                                SVProgressHUD.showError(withStatus: error?.localizedDescription)
                            }
                            
                            else {
                                
                                self.configureCover(cover)
                                
                                if let conversationIndex = self.firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                                    
                                    self.firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto = cover
                                }
                            }
                        }
                    }
                }
            }
            
            else {
                
                self.configureCover(nil)
            }
        }
        
        else if let conversation = collabConversation {
            
            self.configureCover(nil)
        }
    }
    
    private func retrieveProfilePic (member: Member) {
        
        if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == member.userID }) {
            
            if let profilePic = firebaseCollab.friends[friendIndex].profilePictureImage {
                
                configureCover(profilePic)
            }
            
            else if let memberProfilePic = firebaseCollab.membersProfilePics[member.userID] {
                
                configureCover(memberProfilePic)
            }
            
            else {
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: member.userID) { (profilePic, userID) in
                    
                    self.configureProfilePic(profilePic)
                    
                    if profilePic != nil {
                       
                        self.firebaseCollab.cacheMemberProfilePics(userID: member.userID, profilePic: profilePic)
                    }
                }
            }
        }
    }
    
    private func configureVisualEffect () {
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            visualEffectView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
            visualEffectView.heightAnchor.constraint(equalToConstant: 250),
            visualEffectView.centerXAnchor.constraint(equalTo: self.ovalBackgroundView.centerXAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: self.ovalBackgroundView.bottomAnchor, constant: 0)
            
        ].forEach({ $0.isActive = true })

        animator.addAnimations {
            
            self.visualEffectView.effect = UIBlurEffect(style: .dark)
        }

        animator.fractionComplete = 0.3
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            self.animator.stopAnimation(true)
            self.animator.finishAnimation(at: .current)
        }
    }
    
    private func configureCover (_ photo: UIImage?) {
        
        if photo != nil {
            
            ovalBackgroundBottomAnchor.constant = 80
            
            backgroundImageView.image = photo
            
            visualEffectView.isHidden = false
            
            configureCoverContainer(photo: photo)
            configureCoverImageView(photo: photo)
            
            coverPhotoLabel.isHidden = true
        }
        
        else {
            
            ovalBackgroundBottomAnchor.constant = 0
            
            backgroundImageView.image = nil
            
            visualEffectView.isHidden = true
            
            configureCoverContainer(photo: nil)
            configureCoverImageView(photo: nil)
            
            coverPhotoLabel.isHidden = false
            
            if personalConversation != nil {
                
                coverPhotoLabel.text = "Add a Cover Photo"
            }
            
            else if collabConversation != nil {
                
                coverPhotoLabel.text = "No Cover Photo Yet"
            }
        }
    }
    
    private func configureProfilePic (_ photo: UIImage?) {
        
        if photo != nil {
            
            ovalBackgroundBottomAnchor.constant = 80
            
            backgroundImageView.image = photo
            
            visualEffectView.isHidden = false
            
            configureCoverContainer(photo: photo)
            configureCoverImageView(photo: photo)
            
            coverPhotoLabel.isHidden = true
        }
        
        else {
            
            ovalBackgroundBottomAnchor.constant = 80
            
            backgroundImageView.image = nil
            
            visualEffectView.isHidden = true
            
            configureCoverContainer(photo: UIImage(named: "DefaultProfilePic"))
            configureCoverImageView(photo: UIImage(named: "DefaultProfilePic"))
            
            coverPhotoLabel.isHidden = true
        }
    }
    
    private func configureCoverContainer (photo: UIImage?) {
        
        if photo != nil {
            
            coverContainerWidthConstraint.constant = 200
            coverContainerHeightConstraint.constant = 200
            coverContainerBottomAnchor.constant = 5
            
            coverPhotoContainer.layer.shadowRadius = 2.5
            coverPhotoContainer.layer.shadowColor = UIColor(hexString: "39434A")?.cgColor
            coverPhotoContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
            coverPhotoContainer.layer.shadowOpacity = 0.5
            
            coverPhotoContainer.layer.cornerRadius = 100
            coverPhotoContainer.layer.masksToBounds = false
            coverPhotoContainer.clipsToBounds = false
        }
        
        else {
            
            coverPhotoContainer.clipsToBounds = true
        }
    }
    
    private func configureCoverImageView (photo: UIImage?) {
        
        if photo != nil {
            
            coverPhotoImageView.image = photo
            coverPhotoImageView.contentMode = .scaleAspectFill
            
            coverPhotoImageView.layer.cornerRadius = 100
            coverPhotoImageView.clipsToBounds = true
        }
        
        else {
            
            coverPhotoImageView.image = UIImage(named: "Landscape")
            coverPhotoImageView.contentMode = .scaleAspectFit
            
            coverPhotoImageView.layer.cornerRadius = 0
            coverPhotoImageView.clipsToBounds = true
        }
    }
}
