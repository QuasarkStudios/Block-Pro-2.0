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
    
    func configureTableView (bottomInset: CGFloat) {
        
        if let viewController = parentViewController as? MessagingViewController {
            
            tableView.dataSource = viewController
            tableView.delegate = viewController
        }
        
        tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 0
        
        tableView.scrollsToTop = false
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        
        tableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        tableView.register(UINib(nibName: "PhotoMessageCell", bundle: nil), forCellReuseIdentifier: "photoMessageCell")
        tableView.register(UINib(nibName: "PhotoMessageWithCaptionCell", bundle: nil), forCellReuseIdentifier: "photoMessageWithCaptionCell")
    }
    
    
    //MARK: - TableView Datasource Helper Functions
    
    func numberOfRowsInSection (messages: [Message]?) -> Int {
        
        return (messages?.count ?? 0) * 2
    }
    
    func cellForRowAt (indexPath: IndexPath, messages: [Message]?, members: [Member]?) -> UITableViewCell {
        
        if indexPath.row % 2 == 0 {
            
            if messages?[indexPath.row / 2].messagePhoto == nil {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageCell
                cell.members = members
                cell.previousMessage = (indexPath.row / 2) - 1 >= 0 ? messages![(indexPath.row / 2) - 1] : nil
                cell.message = messages?[indexPath.row / 2]
                
                if let viewController = parentViewController as? MessagingViewController {
                    
                    cell.presentCopiedAnimationDelegate = viewController
                }
                
                cell.selectionStyle = .none
                
                return cell
            }
            
            else {
                
                if messages?[indexPath.row / 2].message == nil {
                    
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
                    
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                else {
                    
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
                    
                    cell.selectionStyle = .none

                    return cell
                }
            }
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
            cell.isUserInteractionEnabled = false
            return cell
        }
    }
    
    func heightForRowAt (indexPath: IndexPath, messages: [Message]?) -> CGFloat {
        
        if indexPath.row % 2 == 0 {
            
            return determineMessageRowHeight(indexPath: indexPath, messages: messages)
        }
        
        else {
            
            return determineSeperatorRowHeight(indexPath: indexPath, messages: messages)
        }
    }
    
    
    //MARK: - Determine Message Row Height Function
    
    private func determineMessageRowHeight (indexPath: IndexPath, messages: [Message]?) -> CGFloat {

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
                    
                //If this message doesn't have a photo
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15 //15 is a height increase to the cell to improve it aesthetically
                }
            }
            
            //If another user sent the message
            else {
                
                if let messagePhoto = messages?[indexPath.row].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                    
                    return imageViewHeight + textViewHeight + 31 //16 (15 + 1 for the bottom anchor of the photoImageView) to improve the aesthetics of the cell + an extra 15 to allow for the nameLabel that will be shown in this cell
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 30 //15 to improve the aesthetics of the cell + an extra 15 to allow for the nameLabel that will be shown in this cell
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
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
                }
            }
            
            //If the previous message was sent by another user
            else if messages?[indexPath.row / 2].sender != messages?[(indexPath.row / 2) - 1].sender {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                    
                    return imageViewHeight + textViewHeight + 31
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 30
                }
            }
            
            //If this message and the previous message was sent by the same user
            else {
                
                if let messagePhoto = messages?[indexPath.row / 2].messagePhoto {
                    
                    let imageViewHeight = calculatePhotoMessageCellHeight(messagePhoto: messagePhoto)
                    let textViewHeight = messages?[indexPath.row / 2].message?.estimateFrameForMessageCell().height ?? -16
                    
                    return imageViewHeight + textViewHeight + 16
                }
                
                else {
                    
                    return (messages?[indexPath.row / 2].message!.estimateFrameForMessageCell().height)! + 15
                }
            }
        }
    }
    
    
    //MARK: - Determine Seperator Row Height Function
    
    private func determineSeperatorRowHeight (indexPath: IndexPath, messages: [Message]?) -> CGFloat {
        
        if (indexPath.row / 2) + 1 < messages!.count {
            
            if messages![indexPath.row / 2].sender == messages![(indexPath.row / 2) + 1].sender {
                
                return 2
            }
            
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
    
    //MARK: - Reload TableView Function
    
    func reloadTableView (messages: [Message]?) {

        //If the "messages" array only has one new message that the tableView hasn't yet created a cell for; eveident that the tableView has already been previously loaded
        if (((messages?.count ?? 0) * 2) - 2) == self.tableView.numberOfRows(inSection: 0) {
            
            let seperatorCellIndexPath = IndexPath(row: ((messages?.count ?? 0) * 2) - 2, section: 0)
            let messageCellIndexPath = IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0)

            let lastMessageIndex = messages?.count ?? 0 > 0 ? (messages?.count ?? 0) - 1 : 0
            
            if messages?[lastMessageIndex].sender == self.currentUser.userID {

                tableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .right)
            }

            else {

                tableView.insertRows(at: [seperatorCellIndexPath, messageCellIndexPath], with: .left)
            }
            
            //Scrolls to the last row in the tableView, and animates it
            tableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .bottom, animated: true)
        }
        
        //The tableView hasn't been loaded
        else {
            
            tableView.reloadData()
            
            //Scrolls to the last row in the tableView, but doesn't animate it
            tableView.scrollToRow(at: IndexPath(row: ((messages?.count ?? 0) * 2) - 1, section: 0), at: .bottom, animated: false)
        }
    }
}
