//
//  MessagesInfoViewController.swift
//  Block Pro
//
//  Created by Nimat Azeez on 6/16/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol MoveToConversationWithMemberProtcol: AnyObject {
    
    func moveToConversationWithMember (_ member: Friend)
}

class ConversationInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var messagingInfoTableView: UITableView!
    
    let currentUser = CurrentUser.sharedInstance
    let firebaseMessaging = FirebaseMessaging()
    
    var personalConversation: Conversation? {
        didSet {
            
            //messagingInfoTableView.reloadData()
        }
    }
    
    var collabConversation: Conversation? {
        didSet {
            
            //messagingInfoTableView.reloadData()
        }
    }
    
    var convoName: String?
    
    var membersExpanded: Bool = false
    
    weak var moveToConversationWithMemberDelegate: MoveToConversationWithMemberProtcol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBar.configureNavBar()
        
        configureTableView(tableView: messagingInfoTableView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateConversationName(name: convoName)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if let conversation = personalConversation {
                
                return (conversation.members.count - 1) > 1 ? 1 : 0
            }
            
            else if let conversation = collabConversation {
                
                return (conversation.members.count - 1) > 1 ? 1 : 0
            }
            
            return 0
        }
        
        else {
            
            if let conversation = personalConversation {
                
                return ((conversation.members.count - 1) * 2) + 1
            }
            
            else if let conversation = collabConversation {
                
                return ((conversation.members.count - 1) * 2) + 1
            }
            
            else {
                
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "convoNameInfoCell", for: indexPath) as! ConvoNameInfoCell
            cell.selectionStyle = .none
            cell.personalConversation = personalConversation
            cell.collabConversation = collabConversation
            cell.nameEnteredDelegate = self
            return cell
        }
        
        else {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberHeaderInfoCell", for: indexPath) as! ConvoMemberHeaderInfoCell
                cell.selectionStyle = .none
                
                if let conversation = personalConversation {
                    
                    cell.seeAllLabel.isHidden = (conversation.members.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.members.count - 1) > 3 ? false : true
                }
                
                else if let conversation = collabConversation {
                    
                    cell.seeAllLabel.isHidden = (conversation.members.count - 1) > 3 ? false : true
                    cell.arrowIndicator.isHidden = (conversation.members.count - 1) > 3 ? false : true
                }
                
                return cell
            }
                
            else if indexPath.row % 2 == 0 {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "convoMemberInfoCell", for: indexPath) as! ConvoMemberInfoCell
                cell.conversateWithMemberDelegate = self
                
                if let conversation = personalConversation {
                    
                    var filteredMembers = conversation.members
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    cell.member = filteredMembers[(indexPath.row / 2) - 1]
                    cell.messageButton.isHidden = filteredMembers.count > 1 ? false : true
                }
                
                else if let conversation = collabConversation {
                    
                    var filteredMembers = conversation.members
                    filteredMembers.removeAll(where: { $0.userID == currentUser.userID })
                    
                    cell.member = filteredMembers[(indexPath.row / 2) - 1]
                    cell.messageButton.isHidden = filteredMembers.count > 1 ? false : true
                }
                
                return cell
            }
            
            else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "seperatorCell", for: indexPath)
                cell.isUserInteractionEnabled = false
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
           return 120//144
        }
        
        else {
            
            if indexPath.row == 0 {
                
                return 25
            }
                
            else if indexPath.row % 2 == 0 {
                
                if (indexPath.row / 2) - 1 < 3 {
                    
                    return 70
                }
                
                else {
                    
                    if membersExpanded {
                        
                        return 70
                    }
                    
                    else {
                        
                        return 0
                    }
                }
            }
            
            else {
                
                if indexPath.row == 1 {
                    
                    return 15
                }
                
                else {
                    
                    return 10
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                membersExpanded = !membersExpanded
                
                let cell = tableView.cellForRow(at: indexPath) as! ConvoMemberHeaderInfoCell
                cell.seeAllLabel.text = membersExpanded ? "See less" : "See all"
                cell.transformArrow(expand: membersExpanded)
                
                messagingInfoTableView.beginUpdates()
                messagingInfoTableView.endUpdates()
            }
            
            else {
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    private func configureTableView (tableView: UITableView) {
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "ConvoNameInfoCell", bundle: nil), forCellReuseIdentifier: "convoNameInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberHeaderInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberHeaderInfoCell")
        tableView.register(UINib(nibName: "ConvoMemberInfoCell", bundle: nil), forCellReuseIdentifier: "convoMemberInfoCell")
    }
    
    private func updateConversationName (name: String?) {
        
        if let conversation = personalConversation {
            
            if name?.leniantValidationOfTextEntered() ?? false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, members: conversation.members, name: name!) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversation's name")
                    }
                }
            }
            
            else if name?.leniantValidationOfTextEntered() == false && name != conversation.conversationName {
                
                firebaseMessaging.updateConversationName(conversationID: conversation.conversationID, members: conversation.members, name: nil) { (error) in
                    
                    if error != nil {
                        
                        SVProgressHUD.showError(withStatus: "Sorry, an error occured while changing this conversations name")
                    }
                }
            }
        }
    }
}

extension ConversationInfoViewController: ConvoNameEnteredProtocol {
    
    func convoNameEntered (name: String) {
        
        convoName = name
    }
}

extension ConversationInfoViewController: ConversateWithMemberProtcol {
    
    func conversateWithMember(_ member: Friend) {
        
        dismiss(animated: true) {
            
            self.moveToConversationWithMemberDelegate?.moveToConversationWithMember(member)
        }
    }
}
