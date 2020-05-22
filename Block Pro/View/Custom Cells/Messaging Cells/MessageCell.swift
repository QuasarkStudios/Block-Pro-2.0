//
//  MessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 4/28/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

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
    var collabMembers: [Member]?
    
    var previousMessage: Message?
    var message: Message? {
        didSet {
            
            configureCell(message: message)
            configureProfilePic(message: message)
            configureNameLabel(message: message)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
        messageBubbleView.layer.cornerRadius = 10
        
        if #available(iOS 13.0, *) {
            messageBubbleView.layer.cornerCurve = .continuous
        }
        
        messageTextView.backgroundColor = .clear
        messageTextView.textColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    private func configureCell (message: Message?) {
        
        if message != nil {
            
            messageTextView.text = message!.message
            
            messageBubbleWidthConstraint.constant = message!.message.estimateFrameForMessageCell().width + 30
            
            if message!.sender != currentUser.userID {
                
                messageBubbleTrailingAnchor.isActive = false
                
                messageBubbleLeadingAnchor.constant = 10
                messageBubbleLeadingAnchor.isActive = true
                
                messageBubbleView.backgroundColor = UIColor(hexString: "D8D8D8", withAlpha: 0.50)
                messageTextView.textColor = .black
            }
            
            else {
                
                messageBubbleLeadingAnchor.isActive = false
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
    }
    
    private func configureProfilePic (message: Message?) {
        
        if previousMessage?.sender == message?.sender {
            
            profilePicContainer.isHidden = true
            nameLabel.isHidden = true
            return
        }
        
        else {
            
            nameLabel.isHidden = false
            messageBubbleTopAnchor.constant = 15
        }
        
        if message != nil && collabMembers != nil {
            
            if message!.sender != currentUser.userID {
                
                for member in collabMembers! {
                    
                    if member.userID == message!.sender {
                        
                        profilePicContainer.configureProfilePicContainer(shadowRadius: 2)
                        profilePicImageView.configureProfileImageView(profileImage: member.profilePictureImage)
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
        
        if previousMessage?.sender == message?.sender {
            
            nameLabel.isHidden = true
            picContainerTopAnchor.constant = 3
            messageBubbleTopAnchor.constant = 0
        }
            
        else if message!.sender == currentUser.userID {
            
            nameLabel.isHidden = true
            picContainerTopAnchor.constant = 3
            messageBubbleTopAnchor.constant = 0
        }
        
        else {
            
            nameLabel.isHidden = false
            picContainerTopAnchor.constant = 15
            messageBubbleTopAnchor.constant = 15
            
            for member in collabMembers ?? [] {
                
                if member.userID == message?.sender {
                    
                    let lastInitial = Array(member.lastName)
                    
                    nameLabel.text = "\(member.firstName) \(lastInitial[0])."
                }
            }
        }
    }
}
