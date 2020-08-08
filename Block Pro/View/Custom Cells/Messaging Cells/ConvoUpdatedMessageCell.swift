//
//  ConvoUpdatedMessageCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 8/4/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

class ConvoUpdatedMessageCell: UITableViewCell {

    @IBOutlet weak var convoUpdatedLabel: UILabel!
    
    let currentUser = CurrentUser.sharedInstance
    var member: Member?
    
    var coverUpdated: Bool? {
        didSet {
            
            if let updated = coverUpdated {
                
                configureLabelWhenCoverUpdated(updated)
            }
        }
    }
    
    var nameUpdated: Bool? {
        didSet {
            
            if let updated = nameUpdated {
                
                configureLabelWhenNameUpdated(updated)
            }
        }
    }
    
    var memberJoining: Bool? {
        didSet {
            
            if let joining = memberJoining {
                
                configureLabelWhenMemberJoined(joining)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        convoUpdatedLabel.textColor = UIColor.black.lighten(byPercentage: 0.2)
    }

    private func configureLabelWhenCoverUpdated (_ updated: Bool) {
        
        if let member = member {
            
            let memberName = member.userID == currentUser.userID ? "You" : member.firstName
            
            if updated {
                
                convoUpdatedLabel.text = memberName + " changed the cover"
            }
            
            else {
                
                convoUpdatedLabel.text = memberName + " deleted the cover"
            }
        }
    }
    
    private func configureLabelWhenNameUpdated (_ updated: Bool) {
        
        if let member = member {
            
            let memberName = member.userID == currentUser.userID ? "You" : member.firstName
            
            if updated {
                
                convoUpdatedLabel.text = memberName + " changed the name"
            }
            
            else {
                
                convoUpdatedLabel.text = memberName + " deleted the name"
            }
        }
    }
    
    private func configureLabelWhenMemberJoined (_ memberJoining: Bool) {
        
        if let member = member {
            
            if memberJoining {
                
                convoUpdatedLabel.text = member.firstName + " joined the conversation"
            }
            
            else {
                
                convoUpdatedLabel.text = member.firstName + " left the conversation"
            }
        }
    }
    
}
