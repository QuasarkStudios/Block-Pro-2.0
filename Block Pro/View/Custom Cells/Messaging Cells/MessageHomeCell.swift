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
    @IBOutlet weak var messagePreviewTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var lastMessageDateLabel: UILabel!
    @IBOutlet weak var lastMessageLeadingAnchor: NSLayoutConstraint!
    @IBOutlet weak var lastMessageTrailingAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var unreadMessageIndicator: UIView!
    @IBOutlet weak var unreadIndicatorTrailingAnchor: NSLayoutConstraint!
    
    let profilePic = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
    let coverPic = ProfilePicture(profilePic: UIImage(named: "Mountains")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor(hexString: "F4F4F4", withAlpha: 0.1)!.cgColor)
    
    let doubleProfilePicContainer = UIView()
    let profilePic2Outline = UIView()
    
    let currentUser = CurrentUser.sharedInstance
    
    let firebaseCollab = FirebaseCollab.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseStorage = FirebaseStorage()
    
    var personalConversation: Conversation? {
        didSet {
            
            if personalConversation != nil {
                
                configureConversationPicContainers(members: personalConversation?.currentMembers)
                configureConversationName(conversation: personalConversation, members: personalConversation?.currentMembers)
                configureMessagePreview(conversation: personalConversation)
                configureUnreadMessageIndicator(conversation: personalConversation)
            }
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            if collabConversation != nil {
                
                configureConversationPicContainers(members: collabConversation?.currentMembers)
                configureConversationName(conversation: collabConversation, members: collabConversation?.currentMembers)
                configureMessagePreview(conversation: collabConversation)
                configureUnreadMessageIndicator(conversation: collabConversation)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureCheckBox()
    }
    
    //Handles the cell backgroundColor animation when the cell is tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
        
        profilePic2Outline.backgroundColor = UIColor(hexString: "D8D8D8")?.lighten(byPercentage: 0.1)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        self.backgroundColor = nil
        
        profilePic2Outline.backgroundColor = .white
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseInOut, animations: {
            
            self.backgroundColor = nil
            
            self.profilePic2Outline.backgroundColor = .white
        })
    }
    
    
    //MARK: - Configuration Functions

    func configureConversationPicContainers (members: [Member]?) {

        //If a conversation has a cover photo
        if let conversation = personalConversation, conversation.coverPhotoID != nil {

            configureConvoCoverContainer(personalConversation: conversation)
        }

        else if let conversation = collabConversation, conversation.coverPhotoID != nil {
            
            configureConvoCoverContainer(collabConversation: conversation)
        }

        //If profile pictures should be used
        else {

            if collabConversation != nil {
                
            }
            
            //If only a single profilePicture should be displayed
            if (members?.count ?? 0) <= 2 {

                coverPic.removeFromSuperview()
                doubleProfilePicContainer.removeFromSuperview()

                configureProfilePicContainer(members: members)
            }

            //If two profilePictures should be displayed
            else {

                profilePic.removeFromSuperview()
                coverPic.removeFromSuperview()

                configureDoubleProfilePicContainer(members: members)
            }
        }
    }
    
    private func configureConvoCoverContainer (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
        
        if let conversation = personalConversation {
            
            if coverPic.superview != nil {
                
                retrieveConvoCoverPhoto(personalConversation: conversation)
            }
            
            else {
                
                profilePic.removeFromSuperview()
                doubleProfilePicContainer.removeFromSuperview()
                
                self.addSubview(coverPic)
                
                configureProfilePicContainerConstraints(coverPic)
                
                retrieveConvoCoverPhoto(personalConversation: conversation)
            }
        }
        
        else if let conversation = collabConversation {
            
            profilePic.removeFromSuperview()
            doubleProfilePicContainer.removeFromSuperview()
        }
    }
    
    
    private func configureProfilePicContainer (members: [Member]?) {
        
        if profilePic.superview != nil {
            
            determineProfilePictures(members, profilePictures: [profilePic])
        }
        
        else  {
            
            self.addSubview(profilePic)
            
            configureProfilePicContainerConstraints(profilePic)
            
            determineProfilePictures(members, profilePictures: [profilePic])
        }
    }
    
    
    private func configureDoubleProfilePicContainer (members: [Member]?) {
        
        //Removes the old profilePics from the doubleProfilePicContainer
        for subview in doubleProfilePicContainer.subviews {

            subview.removeFromSuperview()
        }
        
        if doubleProfilePicContainer.superview == nil {
            
            self.addSubview(doubleProfilePicContainer)
            configureProfilePicContainerConstraints(doubleProfilePicContainer)
        }
        
        //Configuring the first profilePic; will be the recessed one
        let profilePic1 = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 2, shadowOpacity: 0.35, borderColor: UIColor.clear.cgColor)
        doubleProfilePicContainer.addSubview(profilePic1)
        
        //Configuring the outline/container for the second profilePic
        profilePic2Outline.backgroundColor = .white
        profilePic2Outline.layer.cornerRadius = 0.5 * 40.5
        profilePic2Outline.clipsToBounds = true
        doubleProfilePicContainer.addSubview(profilePic2Outline)
        
        //Configuring the second profilePic; will be the one in the foreground
        let profilePic2 = ProfilePicture(profilePic: UIImage(named: "DefaultProfilePic")!, shadowRadius: 0, shadowColor: UIColor.clear.cgColor, shadowOpacity: 0, borderColor: UIColor.white.cgColor, borderWidth: 0)
        profilePic2Outline.addSubview(profilePic2)
        
        //Configuring constraints
        profilePic1.translatesAutoresizingMaskIntoConstraints = false
        profilePic2Outline.translatesAutoresizingMaskIntoConstraints = false
        profilePic2.translatesAutoresizingMaskIntoConstraints = false
        
        [
        
            profilePic1.topAnchor.constraint(equalTo: doubleProfilePicContainer.topAnchor, constant: 0),
            profilePic1.leadingAnchor.constraint(equalTo: doubleProfilePicContainer.leadingAnchor, constant: 0),
            profilePic1.widthAnchor.constraint(equalToConstant: 39),
            profilePic1.heightAnchor.constraint(equalToConstant: 39),
            
            profilePic2Outline.bottomAnchor.constraint(equalTo: doubleProfilePicContainer.bottomAnchor, constant: 0),
            profilePic2Outline.trailingAnchor.constraint(equalTo: doubleProfilePicContainer.trailingAnchor, constant: 0),
            profilePic2Outline.widthAnchor.constraint(equalToConstant: 43),
            profilePic2Outline.heightAnchor.constraint(equalToConstant: 43),
            
            profilePic2.widthAnchor.constraint(equalToConstant: 39),
            profilePic2.heightAnchor.constraint(equalToConstant: 39),
            profilePic2.centerXAnchor.constraint(equalTo: profilePic2Outline.centerXAnchor),
            profilePic2.centerYAnchor.constraint(equalTo: profilePic2Outline.centerYAnchor)
        
        ].forEach({ $0.isActive = true })
        
        determineProfilePictures(members, profilePictures: [profilePic1, profilePic2]) //Determines how the profilePics should be set, then sets them
    }
    
    private func configureProfilePicContainerConstraints (_ container: UIView) {
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        [

            container.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            container.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 17),
            container.widthAnchor.constraint(equalToConstant: 53),
            container.heightAnchor.constraint(equalToConstant: 53)
            
        ].forEach( { $0.isActive = true } )
    }
    
    private func configureConversationName (conversation: Conversation?, members: [Member]?) {
        
        if let name = conversation?.conversationName {
            
            messagesTitleLabel.text = name
        }
        
        else if let members = members {
            
            if members.count == 1 {
                
                messagesTitleLabel.text = "Just You"
            }
            
            else {
                
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
        }
        
        else {
            
            messagesTitleLabel.text = "Loading..."
        }
    }
    
    private func configureMessagePreview (conversation: Conversation?) {
        
        let semiBoldText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Medium", size: 14) as Any, NSAttributedString.Key.foregroundColor : UIColor.black]
        let italicText: [NSAttributedString.Key : Any] = [NSAttributedString.Key.font : UIFont(name: "Poppins-Italic", size: 13) as Any, NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: "")
        
        if let messagePreview = conversation?.messagePreview {
            
            //If this is a message with text
            if let messageText = messagePreview.message {
                
                if messagePreview.sender == currentUser.userID {
                        
                    attributedString.append(NSAttributedString(string: "You:  ", attributes: semiBoldText))
                    attributedString.append(NSAttributedString(string: messageText, attributes: italicText))
                    messagePreviewLabel.attributedText = attributedString
                }
                
                else {
                    
                    //If this conversation is a group chat
                    if conversation?.currentMembers.count ?? 0 > 2 {
                        
                        guard let senderName = conversation?.currentMembers.first(where: { $0.userID == messagePreview.sender })?.firstName else { return }
                        
                            attributedString.append(NSAttributedString(string: "\(senderName):  ", attributes: semiBoldText))
                            attributedString.append(NSAttributedString(string: messageText, attributes: italicText))
                    }
                    
                    else {
                        
                        attributedString.append(NSAttributedString(string: messageText, attributes: italicText))
                    }
                    
                    messagePreviewLabel.attributedText = attributedString
                }
            }
                
            //If this is a photoMessage
            else if messagePreview.messagePhoto != nil {
                
                for member in conversation?.currentMembers ?? [] {
                    
                    if member.userID == messagePreview.sender {
                        
                        let memberName = member.userID == currentUser.userID ? "You" : member.firstName
                        
                        attributedString.append(NSAttributedString(string: "\(memberName) sent a photo", attributes: italicText))
                        messagePreviewLabel.attributedText = attributedString
                        
                        break
                    }
                }
            }
                
            //If this a member updated/deleted the cover
            else if let memberUpdatedConversationCover = messagePreview.memberUpdatedConversationCover {
                
                for member in conversation?.currentMembers ?? [] {
                    
                    if member.userID == messagePreview.sender {
                        
                        let memberName = member.userID == currentUser.userID ? "You" : member.firstName
                        
                        if memberUpdatedConversationCover {
                            
                            attributedString.append(NSAttributedString(string: "\(memberName) changed the cover", attributes: italicText))
                            messagePreviewLabel.attributedText = attributedString
                        }
                        
                        else {
                            
                            attributedString.append(NSAttributedString(string: "\(memberName) deleted the cover", attributes: italicText))
                            messagePreviewLabel.attributedText = attributedString
                        }
                        
                        break
                    }
                }
            }
                
            //If this a member updated/deleted the name
            else if let memberUpdatedConversationName = messagePreview.memberUpdatedConversationName {
                
                for member in conversation?.currentMembers ?? [] {
                    
                    if member.userID == messagePreview.sender {
                        
                        let memberName = member.userID == currentUser.userID ? "You" : member.firstName
                        
                        if memberUpdatedConversationName {
                            
                            attributedString.append(NSAttributedString(string: "\(memberName) changed the name", attributes: italicText))
                            messagePreviewLabel.attributedText = attributedString
                        }
                        
                        else {
                            
                            attributedString.append(NSAttributedString(string: "\(memberName) deleted the name", attributes: italicText))
                            messagePreviewLabel.attributedText = attributedString
                        }
                        
                        break
                    }
                }
            }
                
            //If this a member joining/leaving message
            else if let memberJoiningConversation = messagePreview.memberJoiningConversation {
                
                if let memberName = conversation?.historicMembers.first(where: { $0.userID == messagePreview.sender })?.firstName {
                    
                    if memberJoiningConversation {
                        
                        if messagePreview.sender == currentUser.userID {
                            
                            attributedString.append(NSAttributedString(string: "You joined the conversation", attributes: italicText))
                            messagePreviewLabel.attributedText = attributedString
                        }
                        
                        else {
                            
                            attributedString.append(NSAttributedString(string: "\(memberName) joined the conversation", attributes: italicText))
                            messagePreviewLabel.attributedText = attributedString
                        }
                    }
                    
                    else {
                        
                        attributedString.append(NSAttributedString(string: "\(memberName) left the conversation", attributes: italicText))
                        messagePreviewLabel.attributedText = attributedString
                    }
                }
            }
            
            setLastMessageLabel(date: messagePreview.timestamp)
        }
        
        else {
            
            attributedString.append(NSAttributedString(string: "No Messages Yet", attributes: italicText))
            messagePreviewLabel.attributedText = attributedString
            
            //setLastMessageLabel(date: conversation!.dateCreated!)
            
            if conversation?.memberGainedAccessOn?[currentUser.userID] != nil {
                
                setLastMessageLabel(date: firebaseMessaging.convertTimestampToDate(conversation!.memberGainedAccessOn?[currentUser.userID] as Any))
            }
            
            else if let dateCreated = conversation?.dateCreated {
                
                setLastMessageLabel(date: dateCreated)
            }
            
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
    
    private func configureCheckBox () {
        
        checkBox.delegate = self
        
        checkBox.onAnimationType = BEMAnimationType.fill
        checkBox.offAnimationType = BEMAnimationType.fill

        checkBox.alpha = 0
        checkBox.isHidden = true
        checkBox.isUserInteractionEnabled = false
    }
    
    
    //MARK: - Retrieve Convo Cover Photo Function
    
    private func retrieveConvoCoverPhoto (personalConversation: Conversation? = nil, collabConversation: Conversation? = nil) {
        
        if let conversation = personalConversation {
            
            if let cover = firebaseMessaging.personalConversations.first(where: { $0.conversationID == conversation.conversationID })?.conversationCoverPhoto {
                
                coverPic.profilePic = cover
            }
            
            else {
                
                firebaseStorage.retrievePersonalConversationCoverPhoto(conversationID: conversation.conversationID) { (cover, error) in
                    
                    if error != nil {
                        
                        print(error?.localizedDescription as Any)
                    }
                    
                    else {
                        
                        if self.personalConversation?.conversationID == personalConversation?.conversationID {
                            
                            self.coverPic.profilePic = cover
                            
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
    
    
    //MARK: - Determine Profile Pictures Function
    
    private func determineProfilePictures (_ members: [Member]?, profilePictures: [ProfilePicture]) {
        
        //If only user remains; should be the currentUser
        if members?.count ?? 1 == 1 {
            
            if let currentUserProfilePic = currentUser.profilePictureImage {
                
                profilePictures[0].profilePic = currentUserProfilePic
            }
            
            else {
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: currentUser.userID) { (profilePic, userID) in
                    
                    profilePictures[0].profilePic = profilePic
                }
            }
        }
        
        else if members?.count ?? 0 == 2 {
            
            var filteredMembers = members
            filteredMembers?.removeAll(where: { $0.userID == currentUser.userID })
            
            retrieveProfilePicture(member: filteredMembers?.last) { (profilePic) in

               profilePictures[0].profilePic = profilePic
            }
        }
        
        //If this is a group chat
        else if members?.count ?? 0 >= 3 {
            
            var filteredMembers = members
            filteredMembers?.removeAll(where: { $0.userID == currentUser.userID })
            
            let conversation = personalConversation != nil ? personalConversation : collabConversation
            
            //Ensures the person who sent the last message isn't the current user
            //And that the person wasn't sending a leaving message notification
            if let lastMessageSender = conversation?.messagePreview?.sender, lastMessageSender != currentUser.userID, (conversation?.messagePreview?.memberJoiningConversation ?? true) == true {
                
                //Sets profilePic2 (the one in the foreground) to be the pic of the lastMessageSender
                retrieveProfilePicture(member: filteredMembers?.first(where: { $0.userID == lastMessageSender })) { (profilePic) in
                    
                    profilePictures[1].profilePic = profilePic
                }
                
                //Removes the lastMessageSender and sorts the members alphabetically
                filteredMembers?.removeAll(where: { $0.userID == lastMessageSender })
                filteredMembers = filteredMembers?.sorted(by: { $0.firstName < $1.firstName })
                
                //Sets profilePic1 (the one in the background) to be the pic of the first member in the "filteredMembers" array
                retrieveProfilePicture(member: filteredMembers?.first) { (profilePic) in
                    
                    profilePictures[0].profilePic = profilePic
                }
            }
            
            //If the currentUser sent the last message or the message was a leaving message notification
            else {
                
                filteredMembers = filteredMembers?.sorted(by: { $0.firstName < $1.firstName })
            
                //The first member from "filteredMember" will be set to profilePic2
                retrieveProfilePicture(member: filteredMembers?[0]) { (profilePic) in
                    
                    profilePictures[1].profilePic = profilePic
                }
                
                //The second member from "filteredMember" will be set to profilePic1
                retrieveProfilePicture(member: filteredMembers?[1]) { (profilePic) in
                    
                    profilePictures[0].profilePic =  profilePic
                }
            }
        }
    }
    
    
    //MARK: - Retrieve Profile Picture Function
    
    private func retrieveProfilePicture (member: Member?, completion: @escaping ((_ profilePic: UIImage?) -> Void)) {
        
        if let profilePic = firebaseCollab.friends.first(where: { $0.userID == member?.userID })?.profilePictureImage {
            
            completion(profilePic)
        }
        
        else {
               
            if let index = firebaseCollab.friends.firstIndex(where: { $0.userID == member?.userID }) {
                
                firebaseStorage.retrieveUserProfilePicFromStorage(userID: member?.userID ?? "") { (profilePic, userID) in
                    
                    completion(profilePic)
                    
                    self.firebaseCollab.friends[index].profilePictureImage = profilePic
                }
            }
            
            else if let memberProfilePic = firebaseCollab.membersProfilePics[member?.userID ?? ""] {

                completion(memberProfilePic)
            }

            else {

                firebaseStorage.retrieveUserProfilePicFromStorage(userID: member?.userID ?? "") { (profilePic, userID) in

                    
                    completion(profilePic)
                        
                    self.firebaseCollab.cacheMemberProfilePics(userID: member?.userID ?? "", profilePic: profilePic)
                }
            }
        }
    }
    
    
    //MARK: - Set Last Message Label Function
    
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
    
    
    //MARK: - Begin Editing Function
    
    func beginEditing (animate: Bool) {
        
        messagesTitleLeadingAnchor.constant = 115
        
        messagePreviewLeadingAnchor.constant = 117 //2 points larger than title to improve look/alignment
        messagePreviewTrailingAnchor.constant = 8
        
        lastMessageLeadingAnchor.constant = 30
        lastMessageTrailingAnchor.constant = 10
        
        unreadIndicatorTrailingAnchor.constant = -11
        
        self.constraints.forEach { (constraint) in
            
            if constraint.firstAttribute == .leading {
                
                constraint.constant = 43
            }
        }
        
//        let anchorAnimationDuration = animate ? 0.25 : 0
//        let alphaAnimationDuration = animate ? 0.25 : 0
        
        if animate {
            
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                
                self.layoutIfNeeded()
                
            }) { (finished: Bool) in
                
                self.checkBox.isHidden = false
                
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                    
                    self.checkBox.alpha = 1
                })
            }
        }
        
        else {
            
            self.checkBox.isHidden = false
            self.checkBox.alpha = 1
        }
    }
    
    
    //MARK: - End Editing Function
    
    func endEditing (animate: Bool) {
        
        let anchorAnimationDuration = animate ? 0.25 : 0
        let alphaAnimationDuration = animate ? 0.25 : 0
        
        UIView.animate(withDuration: alphaAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            
            self.checkBox.alpha = 0
            
        }) { (finished: Bool) in
            
            self.checkBox.isHidden = true
            
            self.messagesTitleLeadingAnchor.constant = 92.5
            
            self.messagePreviewLeadingAnchor.constant = 94.5 //2 points larger than title to improve look/alignment
            self.messagePreviewTrailingAnchor.constant = 28
            
            self.lastMessageLeadingAnchor.constant = 10
            self.lastMessageTrailingAnchor.constant = 30
            
            self.unreadIndicatorTrailingAnchor.constant = 9
            
            self.constraints.forEach { (constraint) in
                
                if constraint.firstAttribute == .leading {
                    
                    constraint.constant = 17
                }
            }
            
            UIView.animate(withDuration: anchorAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
                
                self.layoutIfNeeded()
            })
        }
    }
}

//MARK: - BEMCheckBoxDelegate Extension
extension MessageHomeCell: BEMCheckBoxDelegate {
    
    func animationDidStop(for checkBox: BEMCheckBox) {
        
        if checkBox.on {

            checkBox.lineWidth = 2
        }

        else {

            checkBox.lineWidth = 1.5
        }
    }
}
