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

protocol ReconfigureMessagingViewFromConvoInfoVC: AnyObject {
    
    func reconfigureView (personalConversation: Conversation?, collabConversation: Conversation?)
}

class ConversationInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messagingInfoTableView: UITableView!
    
    var copiedAnimationView: CopiedAnimationView?
    
    var editCoverButton: UIButton?
    var deleteCoverButton: UIButton?
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseMessaging = FirebaseMessaging.sharedInstance
    let firebaseCollab = FirebaseCollab.sharedInstance
    
    let formatter = DateFormatter()
    
    var personalConversation: Conversation?
    var collabConversation: Conversation?

    var photoMessages: [Message] = []
    var scheduleMessages: [Message] = []
    
    var convoName: String?
    
    var selectedMember: Member?
    
    weak var moveToConversationWithFriendDelegate: MoveToConversationWithFriendProtcol?
    weak var reconfigureViewDelegate: ReconfigureMessagingViewFromConvoInfoVC?
    
    var viewInitiallyLoaded: Bool = false
    var membersExpanded: Bool = false
    
    var zoomingMethods: ZoomingImageViewMethods?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .clear
        
        backgroundView.backgroundColor = UIColor(hexString: "222222")
        
        configureTableView(tableView: messagingInfoTableView)
        configureDismissKeyboardGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
        
        viewInitiallyLoaded = true
        
        animateCoverPhotoCell()
        
        monitorPersonalConversation()
        monitorPersonalConversationMessages()
        
        monitorCollabConversation()
        monitorCollabConversationMessages()
        
        //Initializing here allows the animationView to be removed and readded multiple times
        copiedAnimationView = CopiedAnimationView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUserActiveStatus), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setUserInactiveStatus), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateConversationName(name: convoName)
        
        firebaseMessaging.monitorPersonalConversationListener?.remove()
        firebaseMessaging.monitorCollabConversationListener?.remove()
        
        firebaseMessaging.messageListener?.remove()
        
        copiedAnimationView?.removeCopiedAnimation(remove: true)
        
        reconfigureViewDelegate?.reconfigureView(personalConversation: self.personalConversation, collabConversation: self.collabConversation)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: - TableView DataSource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let conversation = personalConversation {
            
            //Checking to see if membersCount is equal to one signifying that the conversation was a group chat that now only has one member
            //Or that this conversation is a group chat
            if conversation.historicMembers.count > 2 {
                
                return 6
            }
            
            else {
                
                return 5
            }
        }
        
        else {
            
            return 5
        }
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
                
                //If this conversation has 6/6 members added
                if conversation.currentMembers.count == 6 {
                    
                    //The "Member" header cell, all the members minus the current user, and the seperator cells
                    return ((conversation.currentMembers.count - 1) * 2) + 1
                }
                  
                //If this conversation doesn't have 6/6 members added
                else if conversation.currentMembers.count > 1 && conversation.currentMembers.count < 6 {
                    
                    //If this isn't just a personal conversation
                    if conversation.historicMembers.count > 2 {
                        
                        return ((conversation.currentMembers.count - 1) * 2) + 3
                    }
                    
                    //If this is a personal conversation
                    else {
                        
                        //The "Member" header cell, all the members minus the current user, and the seperator cells
                        return ((conversation.currentMembers.count - 1) * 2) + 1
                    }
                }
                
                //If this conversation was a group chat with only the current user remaining
                else {
                    
                    return 3
                }
            }
            
            else if let conversation = collabConversation {
                
                if conversation.currentMembers.count > 1 {
                    
                    //The "Member" header cell, all the members minus the current user, and the seperator cells
                    return ((conversation.currentMembers.count - 1) * 2) + 1
                }
                
                else {
                    
                    return 3
                }
            }

            return 0
        }
        
        else if section == 3 {
            
            //The "Photos" header cell, the seperator cell, and the collectionView cell
            return 3
        }
        
        else if section == 4 {

            //The "Schedules" header cell, the seperator cell, and the collectionView cell
            return 3
        }
        
        else {
            
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "convoCoverInfoCell", for: indexPath) as! ConvoCoverInfoCell
            cell.selectionStyle = .none
            
            if let conversation = personalConversation {
                
                var filteredMembers = conversation.currentMembers
                filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                
                if filteredMembers.count == 1 && conversation.historicMembers.count == 2 {
                    
                    cell.conversationMember = filteredMembers.first //Lets the cell know that this conversation only has one member
                }
            }
            
            cell.personalConversation = personalConversation
            cell.collabConversation = collabConversation
            cell.presentCopiedAnimationDelegate = self
    
            return cell
        }
        
        else if indexPath.section == 1 {
            
            if let conversation = personalConversation {
                
                //If this is a conversation between only two people, then there's no need for the conversationName cell
                if conversation.currentMembers.count == 2 && conversation.historicMembers.count == 2 {
                    
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
                    
                    if conversation.currentMembers.count == 2 {
                        
                        cell.membersLabel.text = "Member"
                    }
                    
                    else {
                        
                        cell.membersLabel.text = "Members"
                    }
                    
                    cell.membersExpanded = membersExpanded
                    
                    //If there is less than 3 additional members, hide the "seeAllLabel" and "arrowIndicator"
                    cell.seeAllLabel.isHidden = (conversation.currentMembers.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.currentMembers.count - 1) > 3 ? false : true
                }
                
                else if let conversation = collabConversation {
                    
                    cell.membersExpanded = membersExpanded
                    
                    //If there is less than 3 additional members, hide the "seeAllLabel" and "arrowIndicator"
                    cell.seeAllLabel.isHidden = (conversation.currentMembers.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.currentMembers.count - 1) > 3 ? false : true
                }
                
                return cell
            }
                
            else if indexPath.row % 2 == 0 {
                
                //The add member cell
                if let conversationMembers = personalConversation?.currentMembers, indexPath.row / 2 == conversationMembers.count {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "convoAddMemberInfoCell", for: indexPath) as! ConvoAddMemberInfoCell
                    cell.selectionStyle = .none
                    cell.members = conversationMembers
                    
                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberInfoCell", for: indexPath) as! ConvoMemberInfoCell
                    cell.conversateWithFriendDelegate = self
                    
                    if let conversation = personalConversation {
                        
                        var filteredMembers = conversation.currentMembers
                        filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                        
                        cell.member = filteredMembers[(indexPath.row / 2) - 1]
                        cell.memberActivity = conversation.memberActivity?[filteredMembers[(indexPath.row / 2) - 1].userID]
                        
                        //If this is a group chat
                        if conversation.historicMembers.count > 2 {
                            
                            //If this member is friends with the currentUser
                            if let friend = firebaseCollab.friends.first(where: { $0.userID == filteredMembers[(indexPath.row / 2) - 1].userID }), friend.accepted == true {
                                
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
                        
                        if conversation.currentMembers.count > 1 {
                            
                            var filteredMembers = conversation.currentMembers
                            filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                            
                            cell.member = filteredMembers[(indexPath.row / 2) - 1]
                            cell.memberActivity = conversation.memberActivity?[filteredMembers[(indexPath.row / 2) - 1].userID]
                            
                            //If this member is friends with the currentUser
                            if let friend = firebaseCollab.friends.first(where: { $0.userID == filteredMembers[(indexPath.row / 2) - 1].userID }), friend.accepted == true {
                                
                                cell.messageButton.isHidden = false
                            }
                            
                            else {
                                
                                cell.messageButton.isHidden = true
                            }
                        }
                        
                        else {
                            
                            if let member = conversation.currentMembers.first {
                                
                                cell.member = member
                                cell.memberActivity = conversation.memberActivity?[member.userID]
                                cell.messageButton.isHidden = true
                                
                                cell.nameLabel.text = "Just You"
                            }
                        }
                    }
                    
                    cell.selectionStyle = .none
                    
                    return cell
                }
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
        
        else if indexPath.section == 3 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
            
            else if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoPhotos_SchedulesHeaderInfoCell", for: indexPath) as! ConvoPhotos_SchedulesHeaderInfoCell
                cell.selectionStyle = .none
                
                cell.headerLabel.text = "Photos"
                
                cell.messageCount = photoMessages.count
                
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
                cell.presentCopiedAnimationDelegate = self
                
                return cell
            }
        }
        
        else if indexPath.section == 4 {
            
            if indexPath.row == 0 {
        
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
            
            else if indexPath.row == 1 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoPhotos_SchedulesHeaderInfoCell", for: indexPath) as! ConvoPhotos_SchedulesHeaderInfoCell
                cell.selectionStyle = .none
                
                cell.headerLabel.text = "Schedules"
                
                cell.messageCount = scheduleMessages.count
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoScheduleInfoCell", for: indexPath) as! ConvoScheduleInfoCell
                cell.selectionStyle = .none
                
                cell.formatter = formatter
                cell.members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers
                cell.scheduleMessages = scheduleMessages.sorted(by: { $0.timestamp > $1.timestamp })
                
                cell.scheduleDelegate = self
                
                return cell
            }
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "leaveConvoCell", for: indexPath) as! LeaveConvoCell
            cell.selectionStyle = .none
            
            cell.leaveConversationDelegate = self
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            
            if !viewInitiallyLoaded {
                
                return 0
            }
            
            else {
                
                //If this conversation has a coverPhoto or this is a conversation between only 2 people, fully expand cell
                if personalConversation?.coverPhotoID != nil {
                    
                    return 305
                }
                    
                //If this is a true personal conversation
                else if personalConversation?.currentMembers.count == 2 && personalConversation?.historicMembers.count == 2 {
                    
                    return 305
                }
                
                //If this conversation has a coverPhoto, fully expand cell
                else if collabConversation?.coverPhotoID != nil {
                        
                    return 305
                }
                
                //If this conversation doesn't have a cover photo
                else {
                    
                    return 250
                }
            }
        }
        
        else if indexPath.section == 1 {
            
            if let conversation = personalConversation {
                
                if conversation.currentMembers.count == 2 && conversation.historicMembers.count == 2 {
                    
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
                    
                    if let conversationMembers = personalConversation?.currentMembers, indexPath.row / 2 == conversationMembers.count {
                        
                        return 50
                    }
                    
                    else {
                        
                        return 70
                    }
                }
                
                else {
                    
                    //If all members should be shown
                    if membersExpanded {
                        
                        if let conversationMembers = personalConversation?.currentMembers, indexPath.row / 2 == conversationMembers.count {
                            
                            return 50
                        }
                        
                        else {
                            
                            return 70
                        }
                    }
                    
                    else {
                        
                        if let conversationMembers = personalConversation?.currentMembers, indexPath.row / 2 == conversationMembers.count {
                            
                            return 50
                        }
                        
                        else {
                            
                            return 0
                        }
                    }
                }
            }
            
            //Seperator cells
            else {
                
                if indexPath.row == 1 {
                    
                    return 15
                }
                
                else {
                    
                    //Seperator cell before the add member cell
                    if let conversationMembers = personalConversation?.currentMembers, ((indexPath.row + 1) / 2) == conversationMembers.count {
                        
                        return 5
                    }
                    
                    else {
                        
                        //Seperator cells in between memberInfo cells
                        if indexPath.row <= 5 || (indexPath.row > 5 && membersExpanded) {
                            
                            return 10
                        }
                        
                        //Seperator cell if the conversation has 6/6 members
                        else {
                            
                            return 0
                        }
                    }
                }
            }
        }
        
        else if indexPath.section == 3 {
            
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
        
        else if indexPath.section == 4 {
            
            if indexPath.row == 0 {
                
                return 20
            }
            
            else if indexPath.row == 1 {
                
                return 25
            }
            
            else {
                
                if scheduleMessages.count == 0 {
                    
                    //Only using this value so that it matches the photosInfoCell's dimensions
                    let itemSize = (UIScreen.main.bounds.width - (40 + 10 + 20)) / 3
                    
                    //itemSize + top and bottom anchor of collectionView + topAnchor of scheduleContainer
                    return itemSize + 20 + 10
                }
                
                else if scheduleMessages.count <= 3 {
                    
                    //Using the standard itemSize because the dimensions of the cell will now mimic that of the VoiceMemoPresentationCell
                    //itemSize + top and bottom anchor of collectionView + topAnchor of scheduleContainer
                    return itemSize + 30
                }
                
                else {
                    
                    //5 is for the line spacing
                    return (itemSize * 2) + 30 + 5
                }
            }
        }
        
        else {
            
            return 80
        }
    }
    
    
    //MARK: - TableView Delegate Method
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if let conversation = personalConversation {
                
                if conversation.coverPhotoID != nil {
                    
                    let cell = messagingInfoTableView.cellForRow(at: indexPath) as! ConvoCoverInfoCell
                    
                    if let conversationIndex = firebaseMessaging.personalConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                        
                        if firebaseMessaging.personalConversations[conversationIndex].conversationCoverPhoto != nil {
                            
                            performZoomOnCoverImageView(coverImageView: cell.coverPhotoImageView)
                        }
                    }
                }
                    
                else if conversation.historicMembers.count == 2 {
                    
                    let cell = messagingInfoTableView.cellForRow(at: indexPath) as! ConvoCoverInfoCell
                    
                    performZoomOnCoverImageView(coverImageView: cell.coverPhotoImageView)
                }
                
                else if conversation.historicMembers.count > 2 {
                    
                    addCoverPhoto()
                }
            }
            
            else if let conversation = collabConversation {
                
                if conversation.coverPhotoID != nil {
                    
                    let cell = messagingInfoTableView.cellForRow(at: indexPath) as! ConvoCoverInfoCell
                    
                    if let conversationIndex = firebaseMessaging.collabConversations.firstIndex(where: { $0.conversationID == conversation.conversationID }) {
                        
                        if firebaseMessaging.collabConversations[conversationIndex].conversationCoverPhoto != nil {
                            
                            performZoomOnCoverImageView(coverImageView: cell.coverPhotoImageView)
                        }
                    }
                }
            }
        }
        
        else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                membersExpanded = !membersExpanded
                
                let cell = tableView.cellForRow(at: indexPath) as! ConvoMemberHeaderInfoCell
                cell.membersExpanded = membersExpanded
                
                messagingInfoTableView.beginUpdates()
                messagingInfoTableView.endUpdates()
            }
                
            else if let conversationMembers = personalConversation?.currentMembers, indexPath.row / 2 == conversationMembers.count {
                    
                let addMembersVC: AddMembersViewController = AddMembersViewController()
                addMembersVC.membersAddedDelegate = self
                addMembersVC.headerLabelText = "Add Members"
                addMembersVC.noFriendsLabel.text = "No Friends\nYet"
                
                addMembersVC.members = firebaseCollab.friends
                addMembersVC.addedMembers = [:]
                
                //Setting the added members for the AddMembersViewController
                for member in personalConversation?.currentMembers ?? [] {
                    
                    if member.userID != currentUser.userID {
                        
                        addMembersVC.addedMembers?[member.userID] = member
                    }
                }
                
                //Creating the navigation controller for the AddMembersViewController
                let addMembersNavigationController = UINavigationController(rootViewController: addMembersVC)
                
                self.present(addMembersNavigationController, animated: true, completion: nil)
            }
            
            else {
                
                if let cell = tableView.cellForRow(at: indexPath) as? ConvoMemberInfoCell {
                    
                    moveToMemberProfileView(cell)
                    
                    cell.profilePicImageView?.layer.shadowColor = UIColor.clear.cgColor
                    cell.profilePicImageView?.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
        
        else if indexPath.section == 3 {
            
            if indexPath.row == 1 {
                
                if photoMessages.count > 6 {
                    
                    performSegue(withIdentifier: "moveToConvoPhotoView", sender: self)
                }
            }
        }
        
        else if indexPath.section == 4 {
            
            if indexPath.row == 1 {
                
                if scheduleMessages.count > 6 {
                    
                    moveToConversationSchedulesView()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y < 0 {
            
            backgroundViewHeightConstraint.constant = abs(scrollView.contentOffset.y)
        }
        
        adjustStatusBarStyle(scrollView)
    }
    
    
    
    //MARK: - Configuration Functions
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 0 //Fixes animation glitches
        
        tableView.contentInset = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: keyWindow?.safeAreaInsets.bottom ?? 0 > 0 ? 0 : 20, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: -topBarHeight, left: 0, bottom: 0, right: 0)
        
        tableView.delaysContentTouches = false
        
        tableView.register(UINib(nibName: "ConvoCoverInfoCell", bundle: nil), forCellReuseIdentifier: "convoCoverInfoCell")
        tableView.register(UINib(nibName: "ConvoNameInfoCell", bundle: nil), forCellReuseIdentifier: "convoNameInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberHeaderInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberHeaderInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberInfoCell")
        tableView.register(UINib(nibName: "ConvoAddMemberInfoCell", bundle: nil), forCellReuseIdentifier: "convoAddMemberInfoCell")
        tableView.register(UINib(nibName: "ConvoPhotos_SchedulesHeaderInfoCell", bundle: nil), forCellReuseIdentifier: "convoPhotos_SchedulesHeaderInfoCell")
        tableView.register(UINib(nibName: "ConvoPhotoInfoCell", bundle: nil), forCellReuseIdentifier: "convoPhotoInfoCell")
        tableView.register(ConvoScheduleInfoCell.self, forCellReuseIdentifier: "convoScheduleInfoCell")
        tableView.register(UINib(nibName: "LeaveConvoCell", bundle: nil), forCellReuseIdentifier: "leaveConvoCell")
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
    
    
    //MARK: - Animate Cover Photo Cell Function
    
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
    
    
    //MARK: - Adjust Status Bar Style Function
    
    private func adjustStatusBarStyle (_ scrollView: UIScrollView) {
        
        if viewInitiallyLoaded {
            
            if let conversation = personalConversation {
                
                //If the cover cell has a cover photo or a profile picture
                if conversation.historicMembers.count == 2 || conversation.coverPhotoID != nil {
                    
                    if scrollView.contentOffset.y > 175 {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
                    }
                    
                    else {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
                    }
                }
                
                //If the cover cell doesn't have a cover photo or a profile picture
                else {
                    
                    if scrollView.contentOffset.y > 200 {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
                    }
                    
                    else {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
                    }
                }
            }
            
            else if let conversation = collabConversation {
                
                //If the cover cell has a cover photo
                if conversation.coverPhotoID != nil {
                    
                    if scrollView.contentOffset.y > 175 {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
                    }
                    
                    else {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
                    }
                }
                
                //If the cover cell doesn't have a cover photo
                else {
                    
                    if scrollView.contentOffset.y > 200 {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .black, barStyleColor: .default)
                    }
                    
                    else {
                        
                        self.navigationController?.navigationBar.configureNavBar(barBackgroundColor: .clear, barTintColor: .white, barStyleColor: .black)
                    }
                }
            }
        }
    }
    
    //MARK: - Personal Conversation Monitoring Functions
    
    func monitorPersonalConversation () {
        
        guard let conversation = personalConversation else { return }
            
            firebaseMessaging.monitorPersonalConversation(conversationID: conversation.conversationID) { [weak self] (updatedConvo) in
                
                if let error = updatedConvo["error"] as? Error {
                    
                    SVProgressHUD.showError(withStatus: error.localizedDescription)
                }
                
                else {
                    
                    if updatedConvo.contains(where: { $0.key == "conversationName" }) {
                        
                        //Conversation name has been changed
                        if updatedConvo["conversationName"] as? String != self?.personalConversation?.conversationName {
                            
                            self?.personalConversation?.conversationName = updatedConvo["conversationName"] as? String
                            
                            if let cell = self?.messagingInfoTableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? ConvoNameInfoCell {
                                
                                //Check to see if the currentUser is editing the conversation name
                                if !cell.nameTextField.isFirstResponder {
                                    
                                    self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                                }
                            }
                            
                            else {
                                
                                self?.messagingInfoTableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                            }
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
                    
                    if updatedConvo.contains(where: { $0.key == "currentMembersIDs" }) {
                        
                        //Current members may have been updated
                        if let memberIDs = updatedConvo["currentMembersIDs"] as? [String] {
                            
                            self?.personalConversation?.currentMembersIDs = memberIDs
                        }
                    }
                    
                    //Conversation members have been changed
                    if updatedConvo.contains(where: { $0.key == "historicMembers" }) && updatedConvo.contains(where: { $0.key == "currentMembers" }){
                        
                        if let historicMembers = updatedConvo["historicMembers"] as? [Member], let currentMembers = updatedConvo["currentMembers"] as? [Member] {
                            
                            self?.personalConversation?.historicMembers = historicMembers
                            self?.personalConversation?.currentMembers = currentMembers
                            
                            self?.membersExpanded = currentMembers.count > 3 ? true : false
                            
                            if self?.membersExpanded ?? false {
                                
                                self?.messagingInfoTableView.reloadSections([2], with: .fade)
                            }
                            
                            else {
                                
                                if currentMembers.count > 3 {
                                    
                                    self?.messagingInfoTableView.reloadSections([2], with: .none)
                                }
                                
                                else {
                                    
                                    self?.messagingInfoTableView.reloadSections([2], with: .fade)
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
                    self?.retrieveNewScheduleMessages(self?.firebaseMessaging.filterScheduleMessages(messages: messages))
                }
            }
    }
    
    
    //MARK: - Collab Conversation Monitoring Functions
    
    func monitorCollabConversation () {
        
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
                                    
                                    if status.value as? Date != self?.collabConversation?.memberActivity?[status.key] as? Date {
                                        
                                        self?.collabConversation?.memberActivity = updatedConvo["memberActivity"] as? [String : Any]

                                        self?.messagingInfoTableView.reloadSections([2], with: .none)

                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    if updatedConvo.contains(where: { $0.key == "currentMembersIDs" }) {
                        
                        //Current members may have been updated
                        if let memberIDs = updatedConvo["currentMembersIDs"] as? [String] {
                            
                            self?.collabConversation?.currentMembersIDs = memberIDs
                        }
                    }
                    
                    //Conversation members have been changed
                    if updatedConvo.contains(where: { $0.key == "historicMembers" }) && updatedConvo.contains(where: { $0.key == "currentMembers" }){
                        
                        if let historicMembers = updatedConvo["historicMembers"] as? [Member], let currentMembers = updatedConvo["currentMembers"] as? [Member] {
                            
                            self?.collabConversation?.historicMembers = historicMembers
                            self?.collabConversation?.currentMembers = currentMembers
                            
                            self?.membersExpanded = currentMembers.count > 3 ? true : false
                            
                            if self?.membersExpanded ?? false {
                                
                                self?.messagingInfoTableView.reloadSections([2], with: .fade)
                            }
                            
                            else {
                                
                                if currentMembers.count > 3 {
                                    
                                    self?.messagingInfoTableView.reloadSections([2], with: .none)
                                }
                                
                                else {
                                    
                                    self?.messagingInfoTableView.reloadSections([2], with: .fade)
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
                    self?.retrieveNewScheduleMessages(self?.firebaseMessaging.filterScheduleMessages(messages: messages))
                }
            }
    }
    
    
    //MARK: - Retrieve New Photo Messages
    
    private func retrieveNewPhotoMessages (_ updatedPhotoMessages: [Message]?) {
        
        //New photo messages have been recieved
        if updatedPhotoMessages?.count ?? 0 > photoMessages.count {
            
            for message in updatedPhotoMessages ?? [] {
                
                if photoMessages.contains(where: { $0.messageID == message.messageID }) == false {
                    
                    photoMessages.append(message)
                }
            }
            
            photoMessages = photoMessages.sorted(by: { $0.timestamp > $1.timestamp })
                
            messagingInfoTableView.reloadSections([3], with: .fade)
        }
    }
    
    
    //MARK: - Retrieve New Schedule Messages
    
    private func retrieveNewScheduleMessages (_ updatedScheduleMessages: [Message]?) {
        
        //New schedule messages have been recieved
        if updatedScheduleMessages?.count ?? 0 > scheduleMessages.count {
            
            for message in updatedScheduleMessages ?? [] {
                
                if scheduleMessages.contains(where: { $0.messageID == message.messageID }) == false {
                    
                    scheduleMessages.append(message)
                }
            }
            
            scheduleMessages.sort(by: { $0.timestamp > $1.timestamp })
            
            messagingInfoTableView.reloadSections([4], with: .fade)
        }
    }
    
    
    //MARK: - Add Cover Photo Function
    
    private func addCoverPhoto () {
        
        let addCoverPhotoAlert = UIAlertController (title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "    Take a Photo", style: .default) { [weak self] (takePhotoAction) in
          
            self?.takePhotoSelected()
        }
        
        let cameraImage = UIImage(named: "camera2")
        takePhotoAction.setValue(cameraImage, forKey: "image")
        takePhotoAction.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        let choosePhotoAction = UIAlertAction(title: "    Choose a Photo", style: .default) { [weak self] (choosePhotoAction) in
            
            self?.choosePhotoSelected()
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
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, name: name!) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversation's name")
                    }
                }
            }
            
            //Name has been removed
            else if name?.leniantValidationOfTextEntered() == false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, name: nil) { (error) in
                    
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
    
    
    //MARK: - Perform Zoom on Cover Function
    
    private func performZoomOnCoverImageView (coverImageView: UIImageView) {

        if let conversation = personalConversation {

            if conversation.historicMembers.count > 2 {

                editCoverButton = configureEditCoverButton()
                deleteCoverButton = configureDeleteCoverButton()
            }
        }

        zoomingMethods = ZoomingImageViewMethods(on: coverImageView, cornerRadius: 100, with: [editCoverButton, deleteCoverButton])

        zoomingMethods?.performZoom()
    }
    
    
    //MARK: - Edit and Delete Button Actions
    
    @objc private func editCoverButtonPressed () {
        
        zoomingMethods?.handleZoomOutOnImageView()

        addCoverPhoto()
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
                    
                    self?.zoomingMethods?.zoomedOutImageView?.isHidden = false
                    
                    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut) {

                        self?.zoomingMethods?.blackBackground?.backgroundColor = .clear
                        self?.zoomingMethods?.optionalButtons.forEach({ $0?.alpha = 0 })
                        self?.zoomingMethods?.zoomedInImageView?.alpha = 0

                    } completion: { (finished: Bool) in

                        self?.zoomingMethods?.blackBackground?.removeFromSuperview()
                        self?.zoomingMethods?.optionalButtons.forEach({ $0?.removeFromSuperview() })
                        self?.zoomingMethods?.zoomedInImageView?.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    
    //MARK: - Leave Conversation Functions
    
    private func presentLeaveConversationAlert () {
        
        let leaveConversationAlert = UIAlertController(title: "Leave this Conversation?", message: "You will also lose access to all the messages from this conversation", preferredStyle: .actionSheet)
        
        let leaveAction = UIAlertAction(title: "Leave", style: .destructive) { [weak self] (leaveAction) in
            
            self?.leaveConversation()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        leaveConversationAlert.addAction(leaveAction)
        leaveConversationAlert.addAction(cancelAction)
        
        present(leaveConversationAlert, animated: true, completion: nil)
    }
    
    private func leaveConversation () {
        
        guard let conversation = personalConversation else { return }
        
            firebaseMessaging.monitorPersonalConversationListener?.remove() //Removing here will fix a array out of bounds error in the monitorPersonalConversation func
        
            firebaseMessaging.leaveConversation(conversationID: conversation.conversationID) { [weak self] (error) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else {
                    
                    self?.navigationController?.popToRootViewController(animated: true)
                }
            }
    }
    
    
    //MARK: - Move To Member Profile View
    
    private func moveToMemberProfileView (_ cell: ConvoMemberInfoCell) {
        
        firebaseMessaging.monitorPersonalConversationListener?.remove()
        firebaseMessaging.monitorCollabConversationListener?.remove()
        
        let memberProfileVC = ConversationMemberProfileViewController()
        memberProfileVC.modalPresentationStyle = .overCurrentContext
        
        memberProfileVC.member = cell.member
        memberProfileVC.memberActivity = cell.memberActivity
        memberProfileVC.memberCell = cell
        
        self.present(memberProfileVC, animated: false) {
            
            memberProfileVC.performZoomPresentationAnimation()
        }
    }
    
    
    //MARK: - Move To Conversation Schedules View
    
    private func moveToConversationSchedulesView () {
        
        let conversationSchedulesVC = ConversationSchedulesViewController()
        
        conversationSchedulesVC.personalConversation = personalConversation
        conversationSchedulesVC.collabConversation = collabConversation
        conversationSchedulesVC.scheduleMessages = scheduleMessages.sorted(by: { $0.timestamp > $1.timestamp })
        
        let conversationSchedulesNavigationController = UINavigationController(rootViewController: conversationSchedulesVC)
        
        self.present(conversationSchedulesNavigationController, animated: true)
    }
    
    
    //MARK: - Prepare for Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "moveToConvoPhotoView" {
            
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
                
                firebaseMessaging.savePersonalConversationCoverPhoto(conversationID: conversation.conversationID, coverPhotoID: coverPhotoID, coverPhoto: selectedImage) { [weak self] (error) in
                    
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

extension ConversationInfoViewController: MembersAdded {
    
    func membersAdded(_ addedMembers: [Any]) {
        
        var members: [Friend] = []
        
        for addedMember in addedMembers {
            
            if let member = addedMember as? Friend {
                
                members.append(member)
            }
        }
        
        if let conversationID = personalConversation?.conversationID {
            
            firebaseMessaging.addNewConversationMembers(conversationID: conversationID, membersToBeAdded: members) { [weak self] (error, fullConversation) in
                
                if error != nil {
                    
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
                
                else if fullConversation {
                    
                    SVProgressHUD.showError(withStatus: "Sorry, this conversation has too many members")
                }
                
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}


//MARK: - CachePhotoProtocol Extension

extension ConversationInfoViewController: CachePhotoProtocol {
    
    func cacheMessagePhoto (messageID: String, photo: UIImage?) {
        
        if let messageIndex = photoMessages.firstIndex(where: { $0.messageID == messageID }) {
            
            photoMessages[messageIndex].messagePhoto?["photo"] = photo
        }
    }
    
    func cacheCollabPhoto(photoID: String, photo: UIImage?) {}
    
    func cacheBlockPhoto(photoID: String, photo: UIImage?) {}
}


//MARK: - ZoomInProtocol Extension

extension ConversationInfoViewController: ZoomInProtocol {
    
    func zoomInOnPhotoImageView(photoImageView: UIImageView) {
        
        zoomingMethods = ZoomingImageViewMethods(on: photoImageView, cornerRadius: 10)
        zoomingMethods?.performZoom()
    }
}


//MARK: - Schedule Protocol

extension ConversationInfoViewController: ScheduleProtocol {
    
    func moveToScheduleView(message: Message) {
        
        let scheduleVC = ScheduleMessageViewController()
        scheduleVC.message = message
        scheduleVC.members = personalConversation != nil ? personalConversation?.historicMembers : collabConversation?.historicMembers
        
        let scheduleNavigationController = UINavigationController(rootViewController: scheduleVC)
        
        self.present(scheduleNavigationController, animated: true)
    }
}


//MARK: - PresentCopiedAnimation Protocol Extension

extension ConversationInfoViewController: PresentCopiedAnimationProtocol {
    
    func presentCopiedAnimation() {
        
        copiedAnimationView?.presentCopiedAnimation(topAnchor: 50)
    }
}

//MARK: - LeaveConversation Protocol Extension

extension ConversationInfoViewController: LeaveConversationProtocol {
    
    func leaveConversationButtonPressed() {
        
        presentLeaveConversationAlert()
    }
}
