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
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var personalConversation: Conversation? {
        didSet {
            
            configureConvoCoverContainer(personalConversation: personalConversation)
            configureProfilePicContainers(members: personalConversation?.members)
            configureConversationName(conversation: personalConversation, members: personalConversation?.members)
            configureMessagePreview(conversation: personalConversation)
            configureUnreadMessageIndicator(conversation: personalConversation)
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            configureConvoCoverContainer(collabConversation: collabConversation)
            configureProfilePicContainers(members: collabConversation?.members)
            configureConversationName(conversation: collabConversation, members: collabConversation?.members)
            configureMessagePreview(conversation: collabConversation)
            configureUnreadMessageIndicator(conversation: collabConversation)
        }
    }
    
    var profilePicContainers: [UIView] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCheckBox()
    }
    
    func configureConvoCoverContainer (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
        
        if let conversation = personalConversation {
            
            if conversation.coverPhotoID != nil {
                
                for container in profilePicContainers {
                    
                    container.removeFromSuperview()
                }
                
                profilePicContainers.removeAll()
                
                let profilePic = ProfilePicture.init(profilePic: UIImage(named: "Abstract")!)
                self.addSubview(profilePic)
                configureProfilePicContainerConstraints(profilePic, top: 25, leading: 17, width: 50, height: 50)
                
                profilePicContainers.append(profilePic)
                
                retrieveConvoCoverPhoto(personalConversation: conversation)
            }
        }
        
        else if let conversation = collabConversation {
            
            if conversation.coverPhotoID != nil {
                
                for container in profilePicContainers {
                    
                    container.removeFromSuperview()
                }
            }
        }
    }
    
    func configureProfilePicContainers (members: [Member]?) {
        
        //Returns out this function if the conversation has a cover photo set
        if let conversation = personalConversation {
            
            if conversation.coverPhotoID != nil {
                
                return
            }
        }
        
        else if let conversation = collabConversation {
            
            if conversation.coverPhotoID != nil {
                
                return
            }
        }
        
        for container in profilePicContainers {
            
            container.removeFromSuperview()
        }
        
        profilePicContainers.removeAll()
        
        if (members?.count ?? 0) - 1 == 1 {
            
            let profilePic = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!)
            self.addSubview(profilePic)
            configureProfilePicContainerConstraints(profilePic, top: 25, leading: 17, width: 50, height: 50)
            
            profilePicContainers.append(profilePic)
        }
        
        else if (members?.count ?? 0) - 1 == 2 {
            
            let profilePic1 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic1)
            configureProfilePicContainerConstraints(profilePic1, top: 25, leading: 15, width: 35, height: 35)
            
            profilePicContainers.append(profilePic1)
            
            let profilePic2 = ProfilePicture.init(profilePic: UIImage(named: "DefaultProfilePic")!, borderColor: UIColor.white.withAlphaComponent(0.75).cgColor)
            self.addSubview(profilePic2)
            configureProfilePicContainerConstraints(profilePic2, top: 35, leading: 34, width: 35, height: 35)
            
            profilePicContainers.append(profilePic2)
        }
        
        else if (members?.count ?? 0) - 1 == 3 {

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
        
        else if (members?.count ?? 0) - 1 >= 4 {
            
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
        
        retrieveProfilePics(members)
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
    
    func configureConversationName (conversation: Conversation?, members: [Member]?) {
        
        if let name = conversation?.conversationName {
            
            messagesTitleLabel.text = name
        }
        
        else if let members = members {
            
            var organizedMembers = members.sorted(by: { $0.firstName < $1.firstName })
            
            if let currentUserIndex = organizedMembers.firstIndex(where: { $0.userID == currentUser.userID }) {
                
                organizedMembers.remove(at: currentUserIndex)
            }
            
            var name: String = ""
    
            for member in organizedMembers {
                    
                if member.userID == organizedMembers.first?.userID {
    
                    name = member.firstName
                }
    
                else if member.userID != organizedMembers.last?.userID {
    
                    name += ", \(member.firstName)"
                }
    
                else {
    
                    name += " & \(member.firstName)"
                }
            }
            
            messagesTitleLabel.text = name
        }
        
        else {
            
            messagesTitleLabel.text = "Loading"
        }
    }
    
    func configureMessagePreview (conversation: Conversation?) {
        
        if let messagePreview = conversation?.messagePreview {
            
            if let messageText = messagePreview.message {
                
                //messagePreviewLabel.font = UIFont(name: "Poppins-Regular", size: 12)
                messagePreviewLabel.text = messageText
            }

            else {
                
                for member in conversation?.members ?? [] {
                    
                    if member.userID == messagePreview.sender {
                        
                        let memberName = member.userID == currentUser.userID ? "You" : member.firstName
                        
                        //messagePreviewLabel.font = UIFont(name: "Poppins-Italic", size: 13)
                        messagePreviewLabel.text = "\(memberName) sent a photo"
                        break
                    }
                }
            }
            
            setLastMessageLabel(date: messagePreview.timestamp)
        }
        
        else {
            
            messagePreviewLabel.text = "No Messages Yet"
            
            setLastMessageLabel(date: conversation!.dateCreated!)
            
            unreadMessageIndicator.isHidden = true
        }
    }
    
    private func configureUnreadMessageIndicator (conversation: Conversation?) {
        
        unreadMessageIndicator.layer.cornerRadius = 0.5 * unreadMessageIndicator.bounds.size.width
        unreadMessageIndicator.clipsToBounds = true
        
        if let lastMessage = conversation?.messagePreview {
            
            if let lastTimeUserActive = conversation?.memberActivity?[currentUser.userID] as? Date {
                
                if lastTimeUserActive > lastMessage.timestamp {
                    
                    unreadMessageIndicator.isHidden = true
                }
                
                else {
                    
                    if lastMessage.sender != currentUser.userID {
                        
                        unreadMessageIndicator.isHidden = false
                    }
                    
                    else {
                        
                        unreadMessageIndicator.isHidden = true
                    }
                }
            }
            
            else {
                
                if lastMessage.sender != currentUser.userID {
                    
                    unreadMessageIndicator.isHidden = false
                }
                    
                else {
                    
                    unreadMessageIndicator.isHidden = true
                }
            }
        }
        
        else {
            
            unreadMessageIndicator.isHidden = true
        }
    }
    
    func configureCheckBox () {
        
        checkBox.onAnimationType = BEMAnimationType.fill
        checkBox.offAnimationType = BEMAnimationType.fill

        checkBox.alpha = 0
        checkBox.isHidden = true
    }
    
    private func retrieveConvoCoverPhoto (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
        
        if let conversation = personalConversation {

            if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                
                if let cover = firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto {
                    
                    let coverPicture = profilePicContainers.first as! ProfilePicture
                    coverPicture.profilePic = cover
                }
                
                else {
                    
                    firebaseStorage.retrievePersonalConversationCoverPhoto(conversationID: conversation.conversationID) { (cover, error) in
                        
                        if error != nil {
                            
                            print(error?.localizedDescription as Any)
                        }
                        
                        else {
                            
                            let profilePicture = self.profilePicContainers.first as! ProfilePicture
                            profilePicture.profilePic = cover
                            
                            if let conversationIndex = self.firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                                
                                self.firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto = cover
                            }
                        }
                    }
                }
            }
        }
        
        else if let conversation = collabConversation {
            
        }
    }
    
    private func retrieveProfilePics (_ members: [Member]?) {
        
//        var organizedMembers = conversation?.members.sorted(by: { $0.firstName < $1.firstName })
        var organizedMembers = members?.sorted(by: { $0.firstName < $1.firstName })
        
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
