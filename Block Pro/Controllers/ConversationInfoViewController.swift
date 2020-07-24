//
//  MessagesInfoViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol MoveToConversationWithFriendProtcol: AnyObject {
    
    func moveToConversationWithFriend (_ friend: Friend)
}

class ConversationInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messagingInfoTableView: UITableView!
    
    var editCoverButton: UIButton?
    var deleteCoverButton: UIButton?
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    var personalConversation: Conversation?
    var collabConversation: Conversation?

    var photoMessages: [Message] = []
    
    var convoName: String?
    
    var selectedMember: Member?
    
    weak var moveToConversationWithFriendDelegate: MoveToConversationWithFriendProtcol?
    
    var viewInitiallyLoaded: Bool = false
    var membersExpanded: Bool = false
    
    var zoomedOutImageView: UIImageView?
    var zoomedOutImageViewFrame: CGRect?
    
    var blackBackground: UIView?
    var zoomedInImageView: UIImageView?
    var zoomedInImageViewFrame: CGRect?
    
    var panGesture: UIPanGestureRecognizer?
    
    var topBarHeight: CGFloat {

        return (UIApplication.shared.statusBarFrame.height) + (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .clear
        
        backgroundView.backgroundColor = UIColor(hexString: "222222")
        
        configureTableView(tableView: messagingInfoTableView)
        configureDismissKeyboardGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white)
        
        viewInitiallyLoaded = true
        
        animateCoverPhotoCell()
        
        monitorPersonalConversation()
        monitorPersonalConversationMessages()
        
        monitorCollabConversation()
        monitorCollabConversationMessages()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateConversationName(name: convoName)
        
        firebaseMessaging.conversationListener?.remove()
        firebaseMessaging.messageListener?.remove()
        
        NotificationCenter.default.removeObserver(self)
    }

    
    //MARK: - TableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            return 1
        }
        
        else if section == 1 {
            
            return 1
        }
        
        else if section == 2 {
            
            if let conversation = personalConversation {
                
                //The "Member" header cell, all the members minus the current user, and the seperator cells
                return ((conversation.members.count - 1) * 2) + 1
            }
            
            else if let conversation = collabConversation {
                
                //The "Member" header cell, all the members minus the current user, and the seperator cells
                return ((conversation.members.count - 1) * 2) + 1
            }
                
            return 0
        }
        
        else {
            
            //The "Photos" header cell, the seperator cell, and the collectionView cell
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "convoCoverInfoCell", for: indexPath) as! ConvoCoverInfoCell
            cell.selectionStyle = .none
            
            if let conversation = personalConversation {
                
                var filteredMembers = conversation.members
                filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                
                if filteredMembers.count == 1 {
                    
                    cell.conversationMember = filteredMembers.first //Lets the cell know that this conversation only has one member
                }
            }
            
            cell.personalConversation = personalConversation
            cell.collabConversation = collabConversation
    
            return cell
        }
        
        else if indexPath.section == 1 {
            
            if let conversation = personalConversation {
                
                //If this is a conversation between only two people, then there's no need for the conversationName cell
                if conversation.members.count == 2 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                    cell.isUserInteractionEnabled = false
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "convoNameInfoCell", for: indexPath) as! ConvoNameInfoCell
                    cell.selectionStyle = .none
                    cell.personalConversation = personalConversation
                    cell.nameEnteredDelegate = self
                    
                    if viewInitiallyLoaded {
                        
                        cell.textFieldContainerCenterYAnchor.constant = 0 //Previously set to anothor value to improve the look of coverPhotoCell animation
                    }
                    
                    return cell
                }
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoNameInfoCell", for: indexPath) as! ConvoNameInfoCell
                cell.selectionStyle = .none
                cell.collabConversation = collabConversation
                cell.nameEnteredDelegate = self
                
                if viewInitiallyLoaded {
                    
                    cell.textFieldContainerCenterYAnchor.constant = 0 //Previously set to anothor value to improve the look of coverPhotoCell animation
                }
                
                return cell
            }
        }
        
        else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberHeaderInfoCell", for: indexPath) as! ConvoMemberHeaderInfoCell
                cell.selectionStyle = .none
                
                if let conversation = personalConversation {
                    
                    if conversation.members.count == 2 {
                        
                        cell.membersLabel.text = "Member"
                    }
                    
                    else {
                        
                        cell.membersLabel.text = "Members"
                    }
                    
                    //If there is less than 3 additional members, hide the "seeAllLabel" and "arrowIndicator"
                    cell.seeAllLabel.isHidden = (conversation.members.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.members.count - 1) > 3 ? false : true
                }
                
                else if let conversation = collabConversation {
                    
                    //If there is less than 3 additional members, hide the "seeAllLabel" and "arrowIndicator"
                    cell.seeAllLabel.isHidden = (conversation.members.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.members.count - 1) > 3 ? false : true
                }
                
                return cell
            }
                
            else if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberInfoCell", for: indexPath) as! ConvoMemberInfoCell
                cell.conversateWithFriendDelegate = self
                
                if let conversation = personalConversation {
                    
                    var filteredMembers = conversation.members
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    cell.member = filteredMembers[(indexPath.row / 2) - 1]
                    cell.memberActivity = conversation.memberActivity?[filteredMembers[(indexPath.row / 2) - 1].userID]
                    
                    if filteredMembers.count > 1 {
                        
                        //If this member isn't friends with the currentUser
                        if firebaseCollab.friends.contains(where: { $0.userID == filteredMembers[(indexPath.row / 2) - 1].userID}) {
                            
                            cell.messageButton.isHidden = false
                        }
                        
                        else {
                            
                            cell.messageButton.isHidden = true
                        }
                    }
                    
                    else {
                        
                        cell.messageButton.isHidden = true
                    }
                }
                
                else if let conversation = collabConversation {
                    
                    var filteredMembers = conversation.members
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    cell.member = filteredMembers[(indexPath.row / 2) - 1]
                    cell.memberActivity = conversation.memberActivity?[filteredMembers[(indexPath.row / 2) - 1].userID]
                    
                    //If this member isn't friends with the currentUser
                    if firebaseCollab.friends.contains(where: { $0.userID == filteredMembers[(indexPath.row / 2) - 1].userID}) {
                        
                        cell.messageButton.isHidden = false
                    }
                    
                    else {
                        
                        cell.messageButton.isHidden = true
                    }
                }
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
        
        else {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
            
            else if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoPhotosHeaderInfoCell", for: indexPath) as! ConvoPhotosHeaderInfoCell
                cell.selectionStyle = .none
                
                if photoMessages.count <= 6 {
                    
                    cell.seeAllLabel.isHidden = true
                    cell.seeAllArrow.isHidden = true
                }
                
                else {
                    
                    cell.seeAllLabel.isHidden = false
                    cell.seeAllArrow.isHidden = false
                }
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoPhotoInfoCell", for: indexPath) as! ConvoPhotoInfoCell
                cell.selectionStyle = .none
                
                cell.messages = photoMessages.sorted(by: { $0.timestamp > $1.timestamp })
                
                cell.conversationID = personalConversation?.conversationID
                cell.collabID = collabConversation?.conversationID
                
                cell.cachePhotoDelegate = self
                cell.zoomInDelegate = self
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if !viewInitiallyLoaded {
                
                return 0
            }
            
            else {
                
                //If this conversation has a coverPhoto or this is a conversation between only 2 people, fully expand cell
                if personalConversation?.coverPhotoID != nil || personalConversation?.members.count == 2 {
                    
                    return 305
                }
                
                //If this conversation has a coverPhoto, fully expand cell
                else if collabConversation?.coverPhotoID != nil {
                        
                    return 305
                }
                
                else {
                    
                    return 250
                }
            }
        }
        
        else if indexPath.section == 1 {
            
            if let conversation = personalConversation {
                
                if conversation.members.count == 2 {
                    
                    return viewInitiallyLoaded ? 10 : 50 //Will be a seperator cell
                }
                
                else {
                    
                    
                    return viewInitiallyLoaded ? 100 : 200
                }
            }
            
            else {
                
                return viewInitiallyLoaded ? 100 : 200
            }
        }
        
        else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                return 25
            }
                
            else if indexPath.row % 2 == 0 {
                
                //If this is one of the first 3 cells
                if (indexPath.row / 2) - 1 < 3 {
                    
                    return 70
                }
                
                else {
                    
                    //If all members should be shown
                    if membersExpanded {
                        
                        return 70
                    }
                    
                    else {
                        
                        return 0
                    }
                }
            }
            
            //Seperator cells
            else {
                
                if indexPath.row == 1 {
                    
                    return 15
                }
                
                else {
                    
                    return 10
                }
            }
        }
        
        else {
            
            if indexPath.row == 0 {
                
                return 20
            }
            
            else if indexPath.row == 1 {
                
                return 25
            }
            
            else {
                
                let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
                
                if photoMessages.count <= 3 {
                    
                    return itemSize + 20 + 20// The item size plus the top and bottom edge insets, i.e. 20 and the top and bottom anchors i.e. 20
                }
                
                else {
                    
                    return (itemSize * 2) + 20 + 20 + 5 //The height of the two rows of items that'll be displayed plus the edge insets, i.e. 20, the top and bottom anchors i.e. 20, and the line spacing i.e. 5
                }
            }
        }
    }
    
    
    //MARK: - TableView Delegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            let vibrateMethods = VibrateMethods()
            vibrateMethods.quickVibrate()
            
            if let conversation = personalConversation {
                
                if conversation.coverPhotoID != nil {
                    
                    let cell = messagingInfoTableView.cellForRow(at: indexPath) as! ConvoCoverInfoCell
                    
                    if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                        
                        if firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto != nil {
                            
                            performZoomOnCoverImageView(coverImageView: cell.coverPhotoImageView)
                        }
                    }
                }
                    
                else if conversation.members.count == 2 {
                    
                    let cell = messagingInfoTableView.cellForRow(at: indexPath) as! ConvoCoverInfoCell
                    
                    performZoomOnCoverImageView(coverImageView: cell.coverPhotoImageView)
                }
                
                else if conversation.members.count > 2 {
                    
                    addCoverPhoto()
                }
            }
            
            else if let conversation = collabConversation {
                
                //perform zoom once cover is available here
            }
        }
        
        else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                membersExpanded = !membersExpanded
                
                let cell = tableView.cellForRow(at: indexPath) as! ConvoMemberHeaderInfoCell
                cell.seeAllLabel.text = membersExpanded ? "See less" : "See all"
                cell.transformArrow(expand: membersExpanded)
                
                messagingInfoTableView.beginUpdates()
                messagingInfoTableView.endUpdates()
            }
            
            else {
                
                guard let cell = tableView.cellForRow(at: indexPath) as? ConvoMemberInfoCell else { return }
                
                    selectedMember = cell.member
                
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                    performSegue(withIdentifier: "moveToFriendProfileView", sender: self)
            }
        }
        
        else if indexPath.section == 3 {
            
            if indexPath.row == 1 {
                
                if photoMessages.count > 6 {
                    
                    performSegue(withIdentifier: "moveToConvoPhotoView", sender: self)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
            
            backgroundViewHeightConstraint.constant = abs(scrollView.contentOffset.y)
        }
    }
    
    //MARK: - Configuration Functions
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.contentInset = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: 0, right: 0)
        
        tableView.register(UINib(nibName: "ConvoCoverInfoCell", bundle: nil), forCellReuseIdentifier: "convoCoverInfoCell")
        tableView.register(UINib(nibName: "ConvoNameInfoCell", bundle: nil), forCellReuseIdentifier: "convoNameInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberHeaderInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberHeaderInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberInfoCell")
        tableView.register(UINib(nibName: "ConvoPhotosHeaderInfoCell", bundle: nil), forCellReuseIdentifier: "convoPhotosHeaderInfoCell")
        tableView.register(UINib(nibName: "ConvoPhotoInfoCell", bundle: nil), forCellReuseIdentifier: "convoPhotoInfoCell")
    }
    
    private func configureEditCoverButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        button.frame = CGRect(x: 15, y: 50, width: 75, height: 35)
        
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .white
        button.alpha = 0
        button.addTarget(self, action: #selector(editCoverButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    private func configureDeleteCoverButton () -> UIButton {
        
        let button = UIButton(type: .system)
        
        let xCoord = self.view.frame.width - (75 + 20)
        button.frame = CGRect(x: xCoord, y: 50, width: 75, height: 35)
        
        button.setTitle("Delete", for: .normal)
        button.titleLabel?.font = UIFont(name: "Poppins-SemiBold", size: 16)
        button.contentHorizontalAlignment = .center
        button.tintColor = .systemRed
        button.alpha = 0
        button.addTarget(self, action: #selector(deleteCoverButtonPressed), for: .touchUpInside)
        
        return button
    }
    
    private func configureDismissKeyboardGesture () {
        
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeyboardTap.cancelsTouchesInView = false
        view.addGestureRecognizer(dismissKeyboardTap)
    }
    
    private func animateCoverPhotoCell () {
        
        if let cell = self.messagingInfoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ConvoNameInfoCell {
            
            cell.textFieldContainerCenterYAnchor.constant = 0
            
            UIView.animate(withDuration: 0.3) {

                cell.self.layoutIfNeeded()
            }
        }
        
        messagingInfoTableView.beginUpdates()
        messagingInfoTableView.endUpdates()
    }
    
    //MARK: - Personal Conversation Monitoring Functions
    
    private func monitorPersonalConversation () {
        
        guard let conversation = personalConversation else { return }
            
            firebaseMessaging.monitorPersonalConversation(conversationID: conversation.conversationID) { [weak self] (updatedConvo) in
                
                if let error = updatedConvo["error"] {
                    
                    print(error as Any)
                }
                
                else {
                    
                    if updatedConvo.contains(where: { $0.key == "conversationName" }) {
                        
                        //Conversation name has been changed
                        if updatedConvo["conversationName"] as? String != self?.personalConversation?.conversationName {
                            
                            self?.personalConversation?.conversationName = updatedConvo["conversationName"] as? String
                            
                            self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        }
                    }
                    
                    //Conversation cover has been changed
                    if updatedConvo.contains(where: { $0.key == "coverPhotoID" }) {
                        
                        if updatedConvo["coverPhotoID"] as? String != self?.personalConversation?.coverPhotoID {
                            
                            self?.personalConversation?.coverPhotoID = updatedConvo["coverPhotoID"] as? String
                            
                            self?.personalConversation?.conversationCoverPhoto = nil
                            
                            self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                    }
                    
                    //Member activity has been updated
                    if updatedConvo.contains(where: { $0.key == "memberActivity" }) {
                        
                        if let activity = updatedConvo["memberActivity"] as? [String : Any] {
                            
                            if activity.count != self?.personalConversation?.memberActivity?.count {
                                
                                self?.personalConversation?.memberActivity = updatedConvo["memberActivity"] as? [String : Any]

                                self?.messagingInfoTableView.reloadSections([2], with: .none)
                            }

                            else {

                                for status in activity {
                                    
                                    if status.value as? Date != self?.personalConversation?.memberActivity?[status.key] as? Date {
                                        
                                        self?.personalConversation?.memberActivity = updatedConvo["memberActivity"] as? [String : Any]

                                        self?.messagingInfoTableView.reloadSections([2], with: .none)

                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    //Conversation members have been changed
                    if updatedConvo.contains(where: { $0.key == "members" }) {

                        if let members = updatedConvo["members"] as? [Member] {
                            
                            if self?.personalConversation?.members.count != members.count {
                                
                                self?.personalConversation?.members = members
                                
                                self?.messagingInfoTableView.reloadSections([2], with: .fade)
                            }
                            
                            else {
                                
                                for member in members {
                                    
                                    if members.contains(where: { $0.userID == member.userID }) == false {
                                        
                                        self?.personalConversation?.members = members
                                        
                                        self?.messagingInfoTableView.reloadSections([2], with: .fade)
                                        
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func monitorPersonalConversationMessages () {
        
        guard let conversation = personalConversation else { return }
        
            firebaseMessaging.retrieveAllPersonalMessages(conversationID: conversation.conversationID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else {
                    
                    self?.retrieveNewPhotoMessages(self?.firebaseMessaging.filterPhotoMessages(messages: messages))
                }
            }
    }
    
    
    //MARK: - Collab Conversation Monitoring Functions
    
    private func monitorCollabConversation () {
        
        guard let conversation = collabConversation else { return }
        
            firebaseMessaging.monitorCollabConversation(collabID: conversation.conversationID) { [weak self] (updatedConvo) in
                
                if let error = updatedConvo["error"] {
                    
                    print(error as Any)
                }
                
                else {
                    
                    if updatedConvo.contains(where: { $0.key == "collabName" }) {
                        
                        //Collab name has been changed
                        if updatedConvo["collabName"] as? String != self?.collabConversation?.conversationName {
                            
                            self?.collabConversation?.conversationName = updatedConvo["collabName"] as? String
                            
                            self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        }
                    }
                    
                    //Collab cover has been changed
                    if updatedConvo.contains(where: { $0.key == "coverPhotoID" }) {
                        
                        if updatedConvo["coverPhotoID"] as? String != self?.collabConversation?.coverPhotoID {
                            
                            self?.collabConversation?.coverPhotoID = updatedConvo["coverPhotoID"] as? String
                            
                            self?.collabConversation?.conversationCoverPhoto = nil
                            
                            self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                    }
                    
                    //Member activity has been updated
                    if updatedConvo.contains(where: { $0.key == "memberActivity" }) {
                        
                        if let activity = updatedConvo["memberActivity"] as? [String : Any] {
                            
                            if activity.count != self?.collabConversation?.memberActivity?.count {
                                
                                self?.collabConversation?.memberActivity = updatedConvo["memberActivity"] as? [String : Any]
                                
                                self?.messagingInfoTableView.reloadSections([2], with: .none)
                            }
                            
                            else {
                                
                                for status in activity {
                                    
                                    if status.value as? Date != self?.personalConversation?.memberActivity?[status.key] as? Date {
                                        
                                        self?.collabConversation?.memberActivity = updatedConvo["memberActivity"] as? [String : Any]

                                        self?.messagingInfoTableView.reloadSections([2], with: .none)

                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    //Collab members have been changed
                    if updatedConvo.contains(where: { $0.key == "members" }) {
                        
                        if let members = updatedConvo["members"] as? [Member] {
                            
                            if self?.collabConversation?.members.count != members.count {
                                
                                self?.collabConversation?.members = members
                                
                                self?.messagingInfoTableView.reloadSections([2], with: .fade)
                            }
                            
                            else {
                                
                                for member in members {
                                    
                                    if members.contains(where: { $0.userID == member.userID }) == false {
                                        
                                        self?.collabConversation?.members = members
                                        
                                        self?.messagingInfoTableView.reloadSections([2], with: .fade)
                                        
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
    }
    
    private func monitorCollabConversationMessages () {
        
        guard let conversation = collabConversation else { return }
        
            firebaseMessaging.retrieveAllCollabMessages(collabID: conversation.conversationID) { [weak self] (messages, error) in
                
                if error != nil {
                    
                    print(error as Any)
                }
                
                else {
                    
                    self?.retrieveNewPhotoMessages(self?.firebaseMessaging.filterPhotoMessages(messages: messages))
                }
            }
    }
    
    
    //MARK: - Retrieve Messages Function
    
    private func retrieveNewPhotoMessages (_ updatedPhotoMessages: [Message]?) {
        
        //New photo messages have been recieved
        if updatedPhotoMessages?.count != photoMessages.count {
            
            for message in updatedPhotoMessages ?? [] {
                
                if photoMessages.contains(where: { $0.messageID == message.messageID }) == false {
                    
                    photoMessages.append(message)
                }
            }
            
            photoMessages = photoMessages.sorted(by: { $0.timestamp < $1.timestamp })
                
            var indexPathsToReload: [IndexPath] = []
            
            //If the "seeAll" indicator should now be shown
            if photoMessages.count == 7 {
                
                indexPathsToReload = [IndexPath(row: 1, section: 3), IndexPath(row: 2, section: 3)]
            }
            
            else {
                
                indexPathsToReload = [IndexPath(row: 2, section: 3)]
            }
            
            messagingInfoTableView.reloadRows(at: indexPathsToReload, with: .fade)
        }
    }
    
    
    //MARK: - Add Cover Photo Function
    
    private func addCoverPhoto () {
        
        let addCoverPhotoAlert = UIAlertController (title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { (takePhotoAction) in
          
            self.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { (choosePhotoAction) in
            
            self.choosePhotoSelected()
        }
        
        let photoImage = UIImage(named: "image")
        choosePhotoAction.setValue(photoImage, forKey: "image")
        choosePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        addCoverPhotoAlert.addAction(takePhotoAction)
        addCoverPhotoAlert.addAction(choosePhotoAction)
        addCoverPhotoAlert.addAction(cancelAction)
        
        present(addCoverPhotoAlert, animated: true, completion: nil)
    }
    
    
    //MARK: - Conversation Name Update Function
    
    private func updateConversationName (name: String?) {
        
        if let conversation = personalConversation {
            
            //New name has been entered
            if name?.leniantValidationOfTextEntered() ?? false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, members: conversation.members, name: name!) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversation's name")
                    }
                }
            }
            
            //Name has been removed
            else if name?.leniantValidationOfTextEntered() == false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, members: conversation.members, name: nil) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversations name")
                    }
                }
            }
        }
    }
    
    
    //MARK: - User Activity Functions
    
    @objc private func setUserActiveStatus () {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.setActivityStatus(conversationID: conversation.conversationID, "now")
        }
        
        else if let collab = collabConversation {
            
            firebaseMessaging.setActivityStatus(collabID: collab.conversationID, "now")
        }
    }
    
    @objc private func setUserInactiveStatus () {
        
        if let conversation = personalConversation {
            
            firebaseMessaging.setActivityStatus(conversationID: conversation.conversationID, Date())
        }
        
        else if let collab = collabConversation {
            
            firebaseMessaging.setActivityStatus(collabID: collab.conversationID, Date())
        }
    }
    
    
    //MARK: - Edit and Delete Button Actions
    
    @objc private func editCoverButtonPressed () {
        
        handleZoomOutOnCoverImageViewWithCompletion {
            
            self.addCoverPhoto()
        }
    }
    
    @objc private func deleteCoverButtonPressed () {
        
        if let conversation = personalConversation {
            
            SVProgressHUD.show()
            
            firebaseMessaging.deletePersonalConversationCoverPhoto(conversationID: conversation.conversationID) { [weak self] (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    SVProgressHUD.dismiss()
                    
                    self?.personalConversation?.coverPhotoID = nil
                    self?.personalConversation?.conversationCoverPhoto = nil
                    self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    
                    self?.zoomedOutImageView?.isHidden = false
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                        
                        self?.blackBackground?.backgroundColor = .clear
                        self?.editCoverButton?.alpha = 0
                        self?.deleteCoverButton?.alpha = 0
                        self?.zoomedInImageView?.alpha = 0
                        
                    }) { (finished: Bool) in
                        
                        self?.blackBackground?.removeFromSuperview()
                        self?.editCoverButton?.removeFromSuperview()
                        self?.deleteCoverButton?.removeFromSuperview()
                        self?.zoomedInImageView?.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToFriendProfileView" {
            
            let memberVC = segue.destination as! FriendProfileViewController
            memberVC.member = selectedMember
        }
        
        else if segue.identifier == "moveToConvoPhotoView" {
            
            let convoPhotosVC = segue.destination as! ConversationPhotosViewController
            convoPhotosVC.conversationID = personalConversation?.conversationID
            convoPhotosVC.collabID = collabConversation?.conversationID
            convoPhotosVC.photoMessages = photoMessages.sorted(by: { $0.timestamp > $1.timestamp })
        }
    }
    
    @objc private func dismissKeyboard () {
        
        view.endEditing(true)
    }
}

//MARK: - UIImagePicker and UINavigationController Extension

extension ConversationInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func takePhotoSelected () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoSelected () {
        
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.configureNavBar()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] {
            
            selectedImageFromPicker = editedImage as? UIImage
        }
        
        else if let originalImage = info[.originalImage] {
            
            selectedImageFromPicker = originalImage as? UIImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            
            SVProgressHUD.show()
            
            if let conversation = personalConversation {
                
                let coverPhotoID = UUID().uuidString
                
                firebaseMessaging.saveConversationCoverPhoto(conversationID: conversation.conversationID, coverPhotoID: coverPhotoID, coverPhoto: selectedImage) { [weak self] (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: error?.localizedDescription)
                    }
                    
                    else {
                        
                        if let conversationIndex = self?.firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                            
                            self?.firebaseMessaging.personalConversations[conversationIndex].coverPhotoID = coverPhotoID
                            self?.firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto = selectedImage
                        }
                        
                        self?.personalConversation?.coverPhotoID = coverPhotoID
                        self?.personalConversation?.conversationCoverPhoto = selectedImage
                        self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                        
                        self?.dismiss(animated: true) {
                            
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }
        
        else {
            
            dismiss(animated: true) {
                
                SVProgressHUD.showError(withStatus: "Sorry, something went wrong selecting this photo")
            }
        }
    }
}


//MARK: - ConvoNameEnteredProtocol Extension

extension ConversationInfoViewController: ConvoNameEnteredProtocol {
    
    func convoNameEntered (name: String) {
        
        convoName = name
    }
}


//MARK: - ConversateWithFriendProtcol Extension

extension ConversationInfoViewController: ConversateWithFriendProtcol {
    
    func conversateWithFriend(_ friend: Friend) {
        
        dismiss(animated: true) {
            
            self.moveToConversationWithFriendDelegate?.moveToConversationWithFriend(friend)
        }
    }
}


//MARK: - CachePhotoProtocol Extension

extension ConversationInfoViewController: CachePhotoProtocol {
    
    func cachePhoto (messageID: String, photo: UIImage?) {
        
        if let messageIndex = photoMessages.firstIndex(where: { $0.messageID == messageID }) {
            
            photoMessages[messageIndex].messagePhoto?["photo"] = photo
        }
    }
}


//MARK: - ZoomInProtocol Extension

extension ConversationInfoViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        performZoomOnPhotoImageView(photoImageView: photoImageView)
    }
}


//MARK: - Zooming and Panning CoverImageView Functions

extension ConversationInfoViewController {
    
    @objc private func performZoomOnCoverImageView (coverImageView: UIImageView) {
            
        self.zoomedOutImageView = coverImageView
        
        blackBackground = UIView(frame: self.view.frame)
        blackBackground?.backgroundColor = .clear
        
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnCoverImageView)))
        
        UIApplication.shared.keyWindow?.addSubview(blackBackground!)
        
        if let conversation = personalConversation {
            
            if conversation.members.count > 2 {
                
                editCoverButton = configureEditCoverButton()
                deleteCoverButton = configureDeleteCoverButton()
                
                UIApplication.shared.keyWindow?.addSubview(editCoverButton!)
                UIApplication.shared.keyWindow?.addSubview(deleteCoverButton!)
            }
        }
        
        else {
            
            editCoverButton = configureEditCoverButton()
            deleteCoverButton = configureDeleteCoverButton()
            
            UIApplication.shared.keyWindow?.addSubview(editCoverButton!)
            UIApplication.shared.keyWindow?.addSubview(deleteCoverButton!)
        }
        
        if let startingFrame = coverImageView.superview?.convert(coverImageView.frame, to: self.view) {
            
            zoomedOutImageViewFrame = startingFrame
            
            let zoomingImageView = UIImageView(frame: zoomedOutImageViewFrame!)
            zoomingImageView.contentMode = .scaleAspectFill
            zoomingImageView.image = coverImageView.image
            zoomingImageView.layer.cornerRadius = 100
            zoomingImageView.clipsToBounds = true
            
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnCoverImageView)))
            
            UIApplication.shared.keyWindow?.addSubview(zoomingImageView)
            zoomedInImageView = zoomingImageView
            
            coverImageView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                self.editCoverButton?.alpha = 1
                self.deleteCoverButton?.alpha = 1
                
                let height = (startingFrame.height / startingFrame.width) * self.view.frame.width
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                zoomingImageView.center = self.view.center
                
                zoomingImageView.layer.cornerRadius = 0
                
            }) { (finished: Bool) in
                
                self.zoomedInImageViewFrame = self.zoomedInImageView?.frame
                
                self.addCoverImageViewPanGesture(view: self.zoomedInImageView)
                self.addCoverImageViewPanGesture(view: self.blackBackground)
            }
        }
    }
    
    @objc private func handleZoomOutOnCoverImageView () {
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                self.editCoverButton?.alpha = 0
                self.deleteCoverButton?.alpha = 0
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = 100
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                self.editCoverButton?.removeFromSuperview()
                self.deleteCoverButton?.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    func handleZoomOutOnCoverImageViewWithCompletion (completion: @escaping (() -> Void)) {
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                self.editCoverButton?.alpha = 0
                self.deleteCoverButton?.alpha = 0
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = 100
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                self.editCoverButton?.removeFromSuperview()
                self.deleteCoverButton?.removeFromSuperview()
                imageView.removeFromSuperview()
                
                completion()
            }
        }
    }
    
    private func addCoverImageViewPanGesture (view: UIView?) {
        
        if view != nil {
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCoverImageViewPan(sender:)))
            
            view?.addGestureRecognizer(panGesture!)
        }
    }
    
    @objc private func handleCoverImageViewPan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            moveCoverImageViewWithPan(sender: sender)
            
        case .ended:
            
            if (zoomedInImageView?.frame.minY ?? 0 > (self.view.frame.height / 2)) {
                
                handleZoomOutOnCoverImageView()
            }
            
            else if (zoomedInImageView?.frame.maxY ?? 0 < (self.view.frame.height / 2)) {
                
                handleZoomOutOnCoverImageView()
            }
            
            else {
                
                returnCoverImageViewToOrigin()
            }
            
        default:
            break
        }
    }
    
    private func moveCoverImageViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        if let imageView = zoomedInImageView {

            let translatedMinYCoord = imageView.frame.minY + translation.y
            let translatedMinXCoord = imageView.frame.minX + translation.x
            let translatedMaxYCoord = imageView.frame.maxY + translation.y
            
            imageView.frame = CGRect(x: translatedMinXCoord, y: translatedMinYCoord, width: imageView.frame.width, height: imageView.frame.height)
            
            if let backgroundView = blackBackground, let zoomedInMinYCoord =  zoomedInImageViewFrame?.minY, let zoomedInMaxYCoord = zoomedInImageViewFrame?.maxY {
                    
                if translatedMinYCoord > zoomedInMinYCoord {
                    
                    let originalMinYDistanceToBottom = view.frame.height - zoomedInMinYCoord
                    let adjustedMinYDistanceToBottom = abs((translatedMinYCoord - (view.frame.height - originalMinYDistanceToBottom)) - originalMinYDistanceToBottom) //tricky but it works
                    let alphaPart = (1 / originalMinYDistanceToBottom)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * adjustedMinYDistanceToBottom)
                    editCoverButton?.alpha = alphaPart * adjustedMinYDistanceToBottom
                    deleteCoverButton?.alpha = alphaPart * adjustedMinYDistanceToBottom
                }
                
                else if translatedMinYCoord < zoomedInMinYCoord {
                    
                    let alphaPart = (1 / zoomedInMaxYCoord)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * translatedMaxYCoord)
                    editCoverButton?.alpha = alphaPart * translatedMaxYCoord
                    deleteCoverButton?.alpha = alphaPart * translatedMaxYCoord
                }
            }
            
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    private func returnCoverImageViewToOrigin () {
        
        if let imageView = zoomedInImageView, let imageViewFrame = zoomedInImageViewFrame {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                self.editCoverButton?.alpha = 1
                self.deleteCoverButton?.alpha = 1
                
                imageView.frame = imageViewFrame
            })
        }
    }
}


//MARK: - Zooming and Panning PhotoImageView Functions

extension ConversationInfoViewController {
    
    private func performZoomOnPhotoImageView (photoImageView: UIImageView) {
        
        self.zoomedOutImageView = photoImageView
        
        blackBackground = UIView(frame: self.view.frame)
        blackBackground?.backgroundColor = .clear
        
        blackBackground?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnPhotoImageView)))
        
        UIApplication.shared.keyWindow?.addSubview(blackBackground!)
        
        if let startingFrame = photoImageView.superview?.convert(photoImageView.frame, to: self.view) {
            
            zoomedOutImageViewFrame = startingFrame
            
            let zoomingImageView = UIImageView(frame: zoomedOutImageViewFrame!)
            zoomingImageView.contentMode = .scaleAspectFill
            zoomingImageView.image = photoImageView.image
            zoomingImageView.layer.cornerRadius = 8
            zoomingImageView.clipsToBounds = true
            
            zoomingImageView.isUserInteractionEnabled = true
            zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutOnPhotoImageView)))
            
            UIApplication.shared.keyWindow?.addSubview(zoomingImageView)
            zoomedInImageView = zoomingImageView
            
            photoImageView.isHidden = true
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                let photoWidth = photoImageView.image?.size.width
                let photoHeight = photoImageView.image?.size.height
                let height = (photoHeight! / photoWidth!) * self.view.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
                zoomingImageView.center = self.view.center
                
                zoomingImageView.layer.cornerRadius = 0
                
            }) { (finished: Bool) in
                
                self.zoomedInImageViewFrame = self.zoomedInImageView?.frame
                
                self.addPhotoImageViewPanGesture(view: self.zoomedInImageView)
                
                self.addPhotoImageViewPanGesture(view: self.blackBackground)
            }
        }
    }
    
    @objc private func handleZoomOutOnPhotoImageView () {
        
        if let imageView = zoomedInImageView {
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .clear
                
                imageView.frame = self.zoomedOutImageViewFrame!
                imageView.layer.cornerRadius = 8
                imageView.clipsToBounds = true
                
            }) { (finished: Bool) in
                
                self.zoomedOutImageView?.isHidden = false
                self.blackBackground?.removeFromSuperview()
                imageView.removeFromSuperview()
            }
        }
    }
    
    private func addPhotoImageViewPanGesture (view: UIView?) {
        
        if view != nil {
            
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePhotoImageViewPan(sender:)))
            
            view?.addGestureRecognizer(panGesture!)
        }
    }
    
    @objc private func handlePhotoImageViewPan (sender: UIPanGestureRecognizer) {
        
        switch sender.state {
            
        case .began, .changed:
            
            movePhotoImageViewWithPan(sender: sender)
            
        case .ended:
            
            if (zoomedInImageView?.frame.minY ?? 0 > (self.view.frame.height / 2)) {
                
                handleZoomOutOnPhotoImageView()
            }
            
            else if (zoomedInImageView?.frame.maxY ?? 0 < (self.view.frame.height / 2)) {
                
                handleZoomOutOnPhotoImageView()
            }
            
            else {
                
                returnPhotoImageViewToOrigin()
            }
            
        default:
            break
        }
    }
    
    private func movePhotoImageViewWithPan (sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        
        if let imageView = zoomedInImageView {
            
            let translatedMinYCoord = imageView.frame.minY + translation.y
            let translatedMinXCoord = imageView.frame.minX + translation.x
            let translatedMaxYCoord = imageView.frame.maxY + translation.y
            
            imageView.frame = CGRect(x: translatedMinXCoord, y: translatedMinYCoord, width: imageView.frame.width, height: imageView.frame.height)
            
            if let backgroundView = blackBackground, let zoomedInMinYCoord = zoomedInImageViewFrame?.minY, let zoomedInMaxYCoord = zoomedInImageViewFrame?.maxY {
                    
                if translatedMinYCoord > zoomedInMinYCoord {
                    
                    let originalMinYDistanceToBottom = view.frame.height - zoomedInMinYCoord
                    let adjustedMinYDistanceToBottom = abs((translatedMinYCoord - (view.frame.height - originalMinYDistanceToBottom)) - originalMinYDistanceToBottom) //tricky but it works
                    let alphaPart = (1 / originalMinYDistanceToBottom)
                    
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * adjustedMinYDistanceToBottom)
                }
                
                else if translatedMinYCoord < zoomedInMinYCoord {
                    
                    let alphaPart = (1 / zoomedInMaxYCoord)
                    backgroundView.backgroundColor = UIColor.black.withAlphaComponent(alphaPart * translatedMaxYCoord)
                }
            }
            
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
    }
    
    private func returnPhotoImageViewToOrigin () {
        
        if let imageView = zoomedInImageView, let imageViewFrame = zoomedInImageViewFrame {
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                
                self.blackBackground?.backgroundColor = .black
                
                imageView.frame = imageViewFrame
            })
        }
    }
}
