//
//  LeaveConvoCell.swift
//  Block Pro
//
//  Created by Nimat Azeez on 7/30/20.
//  Copyright © 2020 Nimat Azeez. All rights reserved.
//

import UIKit

protocol LeaveConversationProtocol: AnyObject {
    
    func leaveConversationButtonPressed()
}

class LeaveConvoCell: UITableViewCell {
    
    weak var leaveConversationDelegate: LeaveConversationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func leaveConversationButton(_ sender: Any) {
        
        leaveConversationDelegate?.leaveConversationButtonPressed()
    }
}
