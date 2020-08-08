//
//  MessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol PresentCopiedAnimationProtocol: AnyObject {
    
    func presentCopiedAnimation ()
}

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var profilePicContainer: UIView!
    @IBOutlet weak var picContainerTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var profilePicImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var messageBubbleView: UIView!
    @IBOutlet weak var messageBubbleTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleTrailingAnchor: NSLayoutConstraint!
    @IBOutlet weak var messageBubbleWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var members: [Member]?
    
    var previousMessage: Message?
    var message: Message? {
        didSet {
            
            configureProfilePic(message: message)
            configureNameLabel(message: message)
            configureMessageBubble(message: message)
        }
    }
    
    weak var presentCopiedAnimationDelegate: PresentCopiedAnimationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPressGesture)
    }
    
    private func configureProfilePic (message: Message?) {
        
        if message?.sender == currentUser.userID {
            
            picContainerTopAnchor.constant = 3
            profilePicContainer.isHidden = true
            return
        }
        
        else if previousMessage?.sender == message?.sender {
            
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
        
        if message != nil && members != nil {
            
            if message!.sender != currentUser.userID {
                
                for member in members! {
                    
                    if member.userID == message!.sender {
                        
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
    
    private func configureMessageBubble (message: Message?) {
        
        if message != nil {
            
            messageBubbleWidthConstraint.constant = message!.message!.estimateFrameForMessageCell().width + 30
            
            messageBubbleView.layer.cornerRadius = 10
            
            if #available(iOS 13.0, *) {
                messageBubbleView.layer.cornerCurve = .continuous
            }
            
            messageTextView.backgroundColor = .clear
            messageTextView.text = message!.message
            
            if message?.sender == currentUser.userID {
                
                messageBubbleTopAnchor.constant = 0
                
                messageBubbleLeadingAnchor.isActive = false
                messageBubbleTrailingAnchor.isActive = true

                messageBubbleView.backgroundColor = UIColor(hexString: "282828", withAlpha: 0.85)
                messageTextView.textColor = .white
            }
            
            else {
                
                if previousMessage?.sender == message?.sender {
                    
                    if previousMessage?.memberJoiningConversation == nil && previousMessage?.memberUpdatedConversationCover == nil && previousMessage?.memberUpdatedConversationName == nil {
                        
                        messageBubbleTopAnchor.constant = 0
                    }
                    
                    else {
                        
                        messageBubbleTopAnchor.constant = 15
                    }
                }
                
                else {
                    
                    messageBubbleTopAnchor.constant = 15
                }
                
                messageBubbleTrailingAnchor.isActive = false
                
                messageBubbleLeadingAnchor.constant = 10
                messageBubbleLeadingAnchor.isActive = true
                
                messageBubbleView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.50)
                messageTextView.textColor = .black
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
    }
    
    @objc func handleLongPress (gesture: UILongPressGestureRecognizer) {
        
        let pressedLocation = gesture.location(in: self.contentView)
        let messageTextViewLocation = messageTextView.superview?.convert(messageTextView.frame, to: self)
        
        if gesture.state == .began {
            
            if messageTextViewLocation?.contains(pressedLocation) ?? false {
                
                let pasteboard = UIPasteboard.general
                pasteboard.string = messageTextView.text
                
                messageBubbleView.performCopyAnimationOnView()
                
                presentCopiedAnimationDelegate?.presentCopiedAnimation()
            }
        }
    }
}
