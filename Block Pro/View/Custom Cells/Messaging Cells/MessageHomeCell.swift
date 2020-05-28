//
//  MessageHomeCell2.swift
//  Block Pro
//
//  Created by Nimat Azeez on 5/19/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import BEMCheckBox

class MessageHomeCell: UITableViewCell {
    
    @IBOutlet weak var checkBox: BEMCheckBox!
    
    @IBOutlet weak var messagesTitleLabel: UILabel!
    @IBOutlet weak var messagesTitleLeadingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var messagePreviewLabel: UILabel!
    @IBOutlet weak var messagePreviewTopAnchor: NSLayoutConstraint!
    @IBOutlet weak var messagePreviewLeadingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var lastMessageLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var lastMessageTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var unreadMessageIndicator: UIView!
    @IBOutlet weak var unreadIndicatorTrailingAnchor: NSLayoutConstraint!
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var conversationID: String = ""
    var conversationCreationDate: Date?
    
    var conversationName: String? {
        didSet {
            
            if let name = conversationName {
                
                messagesTitleLabel.text = name
            }
            
            else {
                
                messagesTitleLabel.text = "Loading..."
            }
        }
    }
    
    var convoMembers: [Member]? {
        didSet {
            
            configureConversationName(members: convoMembers!)
            configureProfilePicContainers()
        }
    }
    
    var messagePreview: Message? {
        didSet {
            
            if let text = messagePreview?.message {
                
                messagePreviewLabel.text = text
                
                setLastMessageLabel(date: messagePreview!.timestamp)
                
                if messagePreview?.readBy?.contains(where: { $0.userID == currentUser.userID }) ?? false {
                    
                    unreadMessageIndicator.isHidden = true
                }
                
                else {
                    
                    unreadMessageIndicator.isHidden = false
                }
            }
            
            else {
                
                messagePreviewLabel.text = "No Messages Yet"
                
                setLastMessageLabel(date: conversationCreationDate!)
                
                unreadMessageIndicator.isHidden = true
            }
        }
    }
    
    var profilePicContainers: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCell()
        configureCheckBox()
    }

    private func configureCell () {
        
        unreadMessageIndicator.layer.cornerRadius = 0.5 * unreadMessageIndicator.bounds.size.width
        unreadMessageIndicator.clipsToBounds = true
    }
    
    func configureConversationName (members: [Member]) {
        
        if conversationName == nil {
            
            var organizedMembers = convoMembers?.sorted(by: { $0.firstName < $1.firstName })
            
            if let currentUserIndex = organizedMembers?.firstIndex(where: { $0.userID == currentUser.userID }) {
                
                organizedMembers?.remove(at: currentUserIndex)
            }
            
            var name: String = ""
    
            for member in organizedMembers ?? [] {
                    
                if member.userID == organizedMembers?.first?.userID {
    
                    name = member.firstName
                }
    
                else if member.userID != organizedMembers?.last?.userID {
    
                    name += ", \(member.firstName)"
                }
    
                else {
    
                    name += " & \(member.firstName)"
                }
            }
            
            messagesTitleLabel.text = name
        }
    }
    
    func configureProfilePicContainers () {
        
        for container in profilePicContainers {
            
            container.removeFromSuperview()
        }
        
        profilePicContainers.removeAll()
        
        if (convoMembers?.count ?? 0) - 1 == 1 {
            
            let profilePic = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!)
            self.addSubview(profilePic)
            configureProfilePicContainerConstraints(profilePic, top: 25, leading: 17, width: 50, height: 50)
            
            profilePicContainers.append(profilePic)
        }
        
        else if (convoMembers?.count ?? 0) - 1 == 2 {
            
            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 25, leading: 15, width: 35, height: 35)
            
            profilePicContainers.append(profilePic1)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 35, leading: 34, width: 35, height: 35)
            
            profilePicContainers.append(profilePic2)
        }
        
        else if (convoMembers?.count ?? 0) - 1 == 3 {

            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 15, leading: 24.5, width: 35, height: 35)
            
            profilePicContainers.append(profilePic1)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 40, leading: 9, width: 35, height: 35)
            
            profilePicContainers.append(profilePic2)
            
            let profilePic3 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic3)
            configureProfilePicContainerConstraints(profilePic3, top: 40, leading: 38, width: 35, height: 35)
            
            profilePicContainers.append(profilePic3)
        }
        
        else if (convoMembers?.count ?? 0) - 1 >= 4 {
            
            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 15, leading: 24.5, width: 35, height: 35)
            
            profilePicContainers.append(profilePic1)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 40, leading: 9, width: 35, height: 35)
            
            profilePicContainers.append(profilePic2)
            
            let profilePic3 = ProfilePicture.init(borderColor: UIColor.white.withAlphaComponent(0.75).cgColor, extraMembers: 2)
            self.addSubview(profilePic3)
            configureProfilePicContainerConstraints(profilePic3, top: 40, leading: 38, width: 35, height: 35)
            
            profilePicContainers.append(profilePic3)
        }
        
        retrieveProfilePics()
    }
    
    func configureProfilePicContainerConstraints (_ container: UIView, top: CGFloat, leading: CGFloat, width: CGFloat, height: CGFloat) {
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        [

            container.topAnchor.constraint(equalTo: self.topAnchor, constant: top),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leading),
            container.widthAnchor.constraint(equalToConstant: width),
            container.heightAnchor.constraint(equalToConstant: height)
            
        ].forEach( { $0.isActive = true } )
    }
    
    func configureCheckBox () {
        
        checkBox.onAnimationType = BEMAnimationType.fill
        checkBox.offAnimationType = BEMAnimationType.fill

        checkBox.alpha = 0
        checkBox.isHidden = true
    }
    
    private func retrieveProfilePics () {
        
        var organizedMembers = convoMembers?.sorted(by: { $0.firstName < $1.firstName })
        
        if let currentUserIndex = organizedMembers?.firstIndex(where: { $0.userID == currentUser.userID }) {
            
            organizedMembers?.remove(at: currentUserIndex)
        }
        
        var count: Int = 0
        
        for profilePicContainer in profilePicContainers {
            
            let profilePicture = profilePicContainer as! ProfilePicture
            
            if profilePicture.profilePic != nil {
                
                if let friendIndex = firebaseCollab.friends.firstIndex(where: { $0.userID == organizedMembers?[count].userID }) {
                    
                    profilePicture.profilePic = firebaseCollab.friends[friendIndex].profilePictureImage
                }
                
                else {
                    
                    if firebaseCollab.membersProfilePics[organizedMembers?[count].userID ?? ""] != nil {

                        profilePicture.profilePic = firebaseCollab.membersProfilePics[organizedMembers?[count].userID ?? ""]!
                    }

                    else {

                        firebaseStorage.retrieveUserProfilePicFromStorage(userID: organizedMembers?[count].userID ?? "") { (profilePic, userID) in
                            
                            profilePicture.profilePic = profilePic
                            
                            if let memberIndex = organizedMembers?.firstIndex(where: { $0.userID == userID }) {
                                
                                self.firebaseCollab.cacheMemberProfilePics(userID: organizedMembers?[memberIndex].userID ?? "", profilePic: profilePic)
                            }
                        }
                    }
                }
            }
            
            count += 1
        }
    }
    
    private func configureMessagePreview () {

        if messagePreviewLabel.frame.height > 20 {

            messagePreviewTopAnchor.constant = 5
        }

        else {

            messagePreviewTopAnchor.constant = 9
        }
    }
    
    private func setLastMessageLabel (date: Date) {
        
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            
            formatter.dateFormat = "h:mm a"
            lastMessageDateLabel.text = formatter.string(from: date)
        }
        
        else if calendar.isDateInYesterday(date) {
            
            lastMessageDateLabel.text = "Yesterday"
        }
        
        else {
            
            formatter.dateFormat = "M/d/yy"
            lastMessageDateLabel.text = formatter.string(from: date)
        }
    }
    
    func increaseProfilePicLeadingAnchor (constant: CGFloat) -> CGFloat {
        
        if profilePicContainers.count == 1 {

            if constant == 17 {
                
                return 41
            }
            
            return constant
        }
        
        else if profilePicContainers.count == 2 {
            
            if constant == 15 {
                return 40
            }
            
            else if constant == 34 {
                return 61
            }
            
            return constant
        }
        
        else {
            
            if constant == 24.5 {
                return 47.5
            }
            
            else if constant == 9 {
                return 32
            }
            
            else if constant == 38 {
                return 61
            }
            
            return constant
        }
    }
    
    func decreaseProfilePicLeadingAnchor (constant: CGFloat) -> CGFloat {
        
        if profilePicContainers.count == 1 {

            if constant == 41 {
                
                return 17
            }
            
            return constant
        }
        
        else if profilePicContainers.count == 2 {
            
            if constant == 40 {
                return 15
            }
            
            else if constant == 61 {
                return 34
            }
            
            return constant
        }
        
        else {
            
            if constant == 47.5 {
                return 24.5
            }
            
            else if constant == 32 {
                return 9
            }
            
            else if constant == 61 {
                return 38
            }
            
            return constant
        }
    }
    
    func beginEditing (animate: Bool) {
        
        messagesTitleLeadingAnchor.constant = 115
        messagePreviewLeadingAnchor.constant = 115
        
        lastMessageLeadingAnchor.constant = 30
        lastMessageTrailingAnchor.constant = 10
        
        unreadIndicatorTrailingAnchor.constant = -11
        
        //Finds the leading constraint for each profilePicContainer
        for container in profilePicContainers {
            
            for constraint in container.superview?.constraints ?? [] {
                
                if (constraint.firstItem as? ProfilePicture) != nil {
                    
                    if constraint.firstAttribute == .leading {
                        
                        constraint.constant = self.increaseProfilePicLeadingAnchor(constant: constraint.constant)
                    }
                }
                
                else if (constraint.secondItem as? ProfilePicture) != nil {
                    
                    if constraint.firstAttribute == .leading {
                        
                        constraint.constant = self.increaseProfilePicLeadingAnchor(constant: constraint.constant)
                    }
                }
            }
        }
        
        let anchorAnimationDuration = animate ? 0.5 : 0
        let alphaAnimationDuration = animate ? 0.2 : 0
        
        UIView.animate(withDuration: anchorAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            
            self.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
            self.checkBox.isHidden = false
            
            UIView.animate(withDuration: alphaAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {

                self.checkBox.alpha = 1
            })
            
        }
    }
    
    func endEditing (animate: Bool) {
        
        let anchorAnimationDuration = animate ? 0.5 : 0
        let alphaAnimationDuration = animate ? 0.2 : 0
        
        UIView.animate(withDuration: alphaAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            
            self.checkBox.alpha = 0
            
        }) { (finished: Bool) in
            
            self.checkBox.isHidden = true
            
            self.messagesTitleLeadingAnchor.constant = 95
            self.messagePreviewLeadingAnchor.constant = 95
            
            self.lastMessageLeadingAnchor.constant = 10
            self.lastMessageTrailingAnchor.constant = 30
            
            self.unreadIndicatorTrailingAnchor.constant = 9
            
            for container in self.profilePicContainers {
                
                for constraint in container.superview?.constraints ?? [] {
                    
                    if (constraint.firstItem as? ProfilePicture) != nil {
                        
                        if constraint.firstAttribute == .leading {
                            
                            constraint.constant = self.decreaseProfilePicLeadingAnchor(constant: constraint.constant)
                        }
                    }
                    
                    else if (constraint.secondItem as? ProfilePicture) != nil {
                        
                        if constraint.firstAttribute == .leading {
                            
                            constraint.constant = self.decreaseProfilePicLeadingAnchor(constant: constraint.constant)
                        }
                    }
                }
            }
            
            UIView.animate(withDuration: anchorAnimationDuration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                
                self.layoutIfNeeded()
            })
        }
    }
}
