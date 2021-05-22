//
//  MessagingMethods.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/23/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import Foundation

class MessagingMethods {
    
    let currentUser = CurrentUser.sharedInstance
    
    let formatter = DateFormatter()
    
    weak var parentViewController: AnyObject?
    
    var tableView: UITableView
    
    var conversationID: String?
    var collabID: String?
    
    
    //MARK: - Initialization
    
    init(parentViewController: AnyObject, tableView: UITableView, conversationID: String? = nil, collabID: String? = nil) {
        
        self.tableView = tableView
        
        self.conversationID = conversationID
        self.collabID = collabID
        
        self.parentViewController = parentViewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Configure Table View Function
    
    func configureTableView () {
        
        if let viewController = parentViewController as? MessagingViewController {
            
            tableView.dataSource = viewController
            tableView.delegate = viewController
            
            let inputAccesoryView = viewController.messageInputAccesoryView

            tableView.contentInsetAdjustmentBehavior = .never
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputAccesoryView.configureSize().height + 5, right: 0)

            if #available(iOS 13.0, *) {
                tableView.automaticallyAdjustsScrollIndicatorInsets = false
            }

            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: inputAccesoryView.configureSize().height, right: 0)
        }
        
        else if let viewController = parentViewController as? CollabViewController {
            
            tableView.dataSource = viewController
            tableView.delegate = viewController
            
            let inputAccesoryView = viewController.messageInputAccesoryView
            
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: inputAccesoryView.configureSize().height + 5, right: 0)
            
            if #available(iOS 13.0, *) {
                tableView.automaticallyAdjustsScrollIndicatorInsets = false
            }
            
            tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: inputAccesoryView.configureSize().height, right: 0)
        }
        
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 0
        
        tableView.scrollsToTop = false
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        tableView.register(UINib(nibName: "PhotoMessageCell", bundle: nil), forCellReuseIdentifier: "photoMessageCell")
        tableView.register(ScheduleMessageCell.self, forCellReuseIdentifier: "scheduleMessageCell")
        tableView.register(UINib(nibName: "PhotoMessageWithCaptionCell", bundle: nil), forCellReuseIdentifier: "photoMessageWithCaptionCell")
        tableView.register(UINib(nibName: "ConvoUpdatedMessageCell", bundle: nil), forCellReuseIdentifier: "convoUpdatedMessageCell")
    }
    
    
    //MARK: - TableView Datasource Helper Functions
    
    func numberOfRowsInSection (messages: [Message]?) -> Int {
        
        return (messages?.count ?? 0) * 2
    }
    
    func cellForRowAt (indexPath: IndexPath, messages: [Message]?, members: [Member]?) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            if messages?[indexPath.row / 2].messagePhoto != nil {
                
                if messages?[indexPath.row / 2].message != nil {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "photoMessageWithCaptionCell", for: indexPath) as! PhotoMessageWithCaptionCell
                    cell.conversationID = conversationID != nil ? conversationID : nil
                    cell.collabID = collabID != nil ? collabID : nil
                    cell.members = members
                    cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                    cell.message = messages?[indexPath.row / 2]
                    
                    if let viewController = parentViewController as? MessagingViewController {
                        
                        cell.cachePhotoDelegate = viewController
                        cell.zoomInDelegate = viewController
                        cell.presentCopiedAnimationDelegate = viewController
                    }
                    
                    else if let viewController = parentViewController as? CollabViewController {
                        
                        cell.cachePhotoDelegate = viewController
                        cell.zoomInDelegate = viewController
                        cell.presentCopiedAnimationDelegate = viewController
                    }
                    
                    cell.selectionStyle = .none

                    return cell
                }
                
                else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "photoMessageCell", for: indexPath) as! PhotoMessageCell
                    cell.conversationID = conversationID
                    cell.collabID = collabID
                    cell.members = members
                    cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                    cell.message = messages?[indexPath.row / 2]
                    
                    if let viewController = parentViewController as? MessagingViewController {
                        
                        cell.cachePhotoDelegate = viewController
                        cell.zoomInDelegate = viewController
                        cell.presentCopiedAnimationDelegate = viewController
                    }
                    
                    else if let viewController = parentViewController as? CollabViewController {
                        
                        cell.cachePhotoDelegate = viewController
                        cell.zoomInDelegate = viewController
                        cell.presentCopiedAnimationDelegate = viewController
                    }
                    
                    cell.selectionStyle = .none
                    
                    return cell
                }
            }
            
            else if messages?[indexPath.row / 2].messageBlocks != nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleMessageCell", for: indexPath) as! ScheduleMessageCell
                cell.selectionStyle = .none
                
                cell.formatter = formatter
                
                cell.members = members
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                if let viewController = parentViewController as? MessagingViewController {
                    
                    cell.scheduleDelegate = viewController
                }
                
                else if let viewController = parentViewController as? CollabViewController {
                    
                    cell.scheduleDelegate = viewController
                }
                
                return cell
            }
            
            else if messages?[indexPath.row / 2].message != nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
                cell.members = members
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                if let viewController = parentViewController as? MessagingViewController {
                    
                    cell.presentCopiedAnimationDelegate = viewController
                }
                
                else if let viewController = parentViewController as? CollabViewController {
                    
                    cell.presentCopiedAnimationDelegate = viewController
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            else if let message = messages?[(indexPath.row / 2)], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoUpdatedMessageCell", for: indexPath) as! ConvoUpdatedMessageCell
                cell.member = members?.first(where: { $0.userID == messages?[indexPath.row / 2].sender })
                
                cell.coverUpdated = messages?[indexPath.row / 2].memberUpdatedConversationCover
                cell.nameUpdated = messages?[indexPath.row / 2].memberUpdatedConversationName
                cell.memberJoining = messages?[indexPath.row / 2].memberJoiningConversation
                
                cell.isUserInteractionEnabled = false
                
                return cell
            }            
                
            //If this type of cell can't be handled 
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func heightForRowAt (indexPath: IndexPath, messages: [Message]?, members: [Member]) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return determineMessageRowHeight(indexPath: indexPath, messages: messages, members: members)
        }
        
        else {
            
            return determineSeperatorRowHeight(indexPath: indexPath, messages: messages)
        }
    }
    
    //MARK: - Determine Message Row Height Function
    
    private func determineMessageRowHeight (indexPath: IndexPath, messages: [Message]?, members: [Member]) -> CGFloat {

        //NOTE: Some comments will only exist in the first "if" block to avoid redundancy; if a certain line is missing a seemingly important comment, it's most likely in the first "if" block
        
        //First message
        if indexPath.row == 0 {
            
            //If the current user sent the message
            if messages?[indexPath.row].sender == currentUser.userID {
                
                //If this message has a photo
                if let messagePhoto = messages?[indexPath.row].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row].message?.estimateFrameForMessageCell().height ?? -16 //Default to 16 if there is no caption to cancel out the extra 16 that will be added to the imageViewHeight in the return
                    
                    return imageViewHeight + textViewHeight + 16 //16 (15 + 1 for the bottom anchor of the photoImageView) is a height increase to the cell to improve it aesthetically
                }
                
                //If this is a schedule message
                else if messages?[indexPath.row].messageBlocks != nil {
                    
                    return calculateScheduleMessageCellHeight(messages?[indexPath.row], members)
                }
                    
                //If this is just a simple message
                else if let message = messages?[indexPath.row].message {
                    
                    return message.estimateFrameForMessageCell().height + 15 //15 is a height increase to the cell to improve it aesthetically
                }
                   
                //If this is a convo update message
                else if let message = messages?[indexPath.row], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 20
                }
                
                //If this message is unable to be handled
                else {
                    
                    return 0
                }
            }
            
            //If another user sent the message
            else {
                
                if let messagePhoto = messages?[indexPath.row].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                    
                    return imageViewHeight + textViewHeight + 31 //16 (15 + 1 for the bottom anchor of the photoImageView) to improve the aesthetics of the cell + an extra 15 to allow for the nameLabel that will be shown in this cell
                }
                
                else if messages?[indexPath.row / 2].messageBlocks != nil {
                    
                    return calculateScheduleMessageCellHeight(messages?[indexPath.row / 2], members) + 15
                }
                
                else if let message = messages?[indexPath.row / 2].message {
                    
                    return message.estimateFrameForMessageCell().height + 30 //15 to improve the aesthetics of the cell + an extra 15 to allow for the nameLabel that will be shown in this cell
                }
                    
                else if let message = messages?[indexPath.row / 2], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 20
                }
                
                else {
                    
                    return 0
                }
            }
        }
        
        //Not the first message
        else {
            
            //If the current user sent the message
            if messages?[indexPath.row / 2].sender == currentUser.userID {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                    
                    return imageViewHeight + textViewHeight + 16
                }
                
                else if messages?[indexPath.row / 2].messageBlocks != nil {
                    
                    return calculateScheduleMessageCellHeight(messages?[indexPath.row / 2], members)
                }
                
                else if let message = messages?[indexPath.row / 2].message {
                    
                    return message.estimateFrameForMessageCell().height + 15
                }
                 
                else if let message = messages?[indexPath.row / 2], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 20
                }
                
                else {
                    
                    return 0
                }
            }
            
            //If the previous message was sent by another user
            else if messages?[indexPath.row / 2].sender != messages?[(indexPath.row / 2) - 1].sender {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                    
                    return imageViewHeight + textViewHeight + 31
                }
                
                else if messages?[indexPath.row / 2].messageBlocks != nil {
                    
                    return calculateScheduleMessageCellHeight(messages?[indexPath.row / 2], members) + 15
                }
                
                else if let message = messages?[indexPath.row / 2].message {
                    
                    return message.estimateFrameForMessageCell().height + 30
                }
                
                else if let message = messages?[indexPath.row / 2], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 20
                }
                
                else {
                    
                    return 0
                }
            }
            
            //If this message and the previous message was sent by the same user
            else {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    //If the last message was a convo update message, this cell should show the user's profile pic and name
                    if let message = messages?[(indexPath.row / 2) - 1], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                        
                        let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                        let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                        
                        return imageViewHeight + textViewHeight + 31
                    }
                    
                    else {
                        
                        let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                        let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                        
                        return imageViewHeight + textViewHeight + 16
                    }
                }
                
                else if messages?[indexPath.row / 2].messageBlocks != nil {
                    
                    return calculateScheduleMessageCellHeight(messages?[indexPath.row / 2], members)
                }
                
                else if let message = messages?[indexPath.row / 2].message {
                    
                    //If the last message was a convo update message, this cell should show the user's profile pic and name
                    if let message = messages?[(indexPath.row / 2) - 1], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                        
                        
                        return messages![indexPath.row / 2].message!.estimateFrameForMessageCell().height + 30
                    }
                    
                    else {
                        
                        return message.estimateFrameForMessageCell().height + 15
                    }
                }
                
                else if let message = messages?[indexPath.row / 2], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 20
                }
                
                else {
                    
                    return 0
                }
            }
        }
    }
    
    
    //MARK: - Determine Seperator Row Height Function
    
    private func determineSeperatorRowHeight (indexPath: IndexPath, messages: [Message]?) -> CGFloat {
        
        if (indexPath.row / 2) + 1 < messages!.count {
            
            //If the same user sent the message before and after the seperator cell
            if messages![indexPath.row / 2].sender == messages![(indexPath.row / 2) + 1].sender {
                
                //If the message before the seperator cell is a convo update message
                if let message = messages?[(indexPath.row / 2)], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 8
                }
                    
                //If the message after the seperator cell is a convo update message
                else if let message = messages?[(indexPath.row / 2) + 1], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    return 8
                }
                
                else {
                    
                    return 2
                }
            }
            
            //If the same user didn't send the message before and after the seperator cell
            else {
                
                return 8
            }
        }
        
        else {
            
            return 0
        }
    }
    
    
    //MARK: - Calc PhotoMessageCell Height Function
    
    private func calculatePhotoMessageCellHeight (messagePhoto: [String : Any]) -> CGFloat {
        
        let photoWidth = messagePhoto["photoWidth"] as! CGFloat
        let photoHeight = messagePhoto["photoHeight"] as! CGFloat
        let height = (photoHeight / photoWidth) * 200
        
        return height
    }
    
    
    //MARK: - Calc ScheduleMessageCell Height
    
    private func calculateScheduleMessageCellHeight (_ message: Message?, _ members: [Member] ) -> CGFloat{
        
        if let dateForBlocks = message?.dateForBlocks {
            
            var scheduleLabelText: String = ""
            
            scheduleLabelText = message?.sender == currentUser.userID ? "Here's my schedule for " : "Here's \(members.first(where: { $0.userID == message?.sender })?.firstName ?? "")'s schedule for "
            
            formatter.dateFormat = "EEEE, MMMM d"
            scheduleLabelText += formatter.string(from: dateForBlocks)
            
            scheduleLabelText += dateForBlocks.daySuffix() + ", "
            
            formatter.dateFormat = "yyyy"
            scheduleLabelText += formatter.string(from: dateForBlocks)
            
            return scheduleLabelText.estimateFrameForMessageScheduleLabel().height + 100
        }
        
        else {
            
            return 0
        }
    }
    
    
    //MARK: - Reload TableView Function
    
    func reloadTableView (messages: [Message]?, _ animate: Bool = true) {
        
        //If the "messages" array only has one new message that the tableView hasn't yet created a cell for and the animation parameter is equal to true
        if (((messages?.count ?? 0) * 2) - 2) == self.tableView.numberOfRows(inSection: 0) && animate {
            
            let seperatorCellIndexPath = IndexPath(row: ((messages?.count ?? 0) * 2) - 2, section: 0)
            let messageCellIndexPath = IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0)

            let lastMessageIndex = messages?.count ?? 0 > 0 ? (messages?.count ?? 0) - 1 : 0
            let newMessageIndex = (messages?.count ?? 0) - 1
            
            if messages?[lastMessageIndex].sender == self.currentUser.userID {

                //If the new message is a convo update message
                if let message = messages?[newMessageIndex], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    tableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .fade)
                }
                
                else {
                    
                    tableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .right)
                }
            }

            else {

                //If the new message is a convo update message
                if let message = messages?[newMessageIndex], message.memberUpdatedConversationCover != nil || message.memberUpdatedConversationName != nil || message.memberJoiningConversation != nil {
                    
                    tableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .fade)
                }
                
                else {
                    
                    tableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .left)
                }
            }
            
            //Scrolls to the last row in the tableView, and animates it
            tableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .bottom, animated: true)
        }
        
        //The tableView hasn't been loaded or if the animation parameter is false
        else {
            
            tableView.reloadData()
            
            if messages?.count ?? 0 > 0 {
                
                //Scrolls to the last row in the tableView, but doesn't animate it
                tableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
}
